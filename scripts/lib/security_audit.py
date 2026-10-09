"""Report locations, never matching credential values. This is a heuristic scan."""
from pathlib import Path
import argparse
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
TOKEN = re.compile(rb'(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{50,}|xox[baprs]-[A-Za-z0-9-]{12,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9_-]{32,}|BEGIN [A-Z ]*PRIVATE KEY)')
ABSOLUTE = re.compile(rb'/Users/[a-zA-Z0-9._-]+')
MAIL = re.compile(rb'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')

def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])

def check_bytes(data, label, extra=False):
    hits = []
    for number, line in enumerate(data.splitlines(), 1):
        if TOKEN.search(line):
            hits.append((label, number, 'credential-like content'))
        if extra and ABSOLUTE.search(line):
            hits.append((label, number, 'absolute home path'))
        if extra and 'zsh/.p10k.zsh' not in label:
            addresses = MAIL.findall(line)
            if any(not a.endswith(b'users.noreply.github.com') for a in addresses):
                hits.append((label, number, 'email address'))
    return hits

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--history', action='store_true')
    args=parser.parse_args()
    findings=[]
    if args.history:
        batch=subprocess.Popen(['git','-C',str(ROOT),'cat-file','--batch'],stdin=subprocess.PIPE,stdout=subprocess.PIPE)
        try:
            for entry in git('rev-list','--objects','--all').splitlines():
                oid=entry.split(b' ',1)[0]
                batch.stdin.write(oid+b'\n');batch.stdin.flush()
                header=batch.stdout.readline().split()
                if len(header)!=3:raise RuntimeError('Invalid git object response')
                size=int(header[2]);data=batch.stdout.read(size);batch.stdout.read(1)
                if header[1]==b'blob': findings.extend(check_bytes(data,'history:'+oid.decode()))
        finally:
            batch.stdin.close();batch.stdout.close();batch.wait()
    else:
        names=git('ls-files','--cached','--others','--exclude-standard','-z').split(b'\0')
        deny=Path.home()/'.dotfiles-deny-patterns'
        patterns=[]
        if deny.is_file():
            patterns=[re.compile(s,re.I) for s in deny.read_text().splitlines() if s.strip() and not s.lstrip().startswith('#')]
        for name in sorted(set(names)):
            if not name:continue
            label=name.decode(errors='replace');p=ROOT/label
            if not p.is_file() or p.is_symlink():continue
            data=p.read_bytes()
            findings.extend(check_bytes(data,label,extra=True))
            for number,line in enumerate(data.decode(errors='replace').splitlines(),1):
                if any(pattern.search(line) for pattern in patterns):findings.append((label,number,'local deny pattern'))
    for label,number,kind in findings:print(f'{label}:{number}: {kind} (value redacted)')
    if not findings:print('No matches in '+('Git history' if args.history else 'working files')+' (heuristic scan).')
    return bool(findings)

if __name__=='__main__':sys.exit(main())
