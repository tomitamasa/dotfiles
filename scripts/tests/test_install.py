import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]

class InstallSafety(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        self.bin = self.home / 'bin'
        self.bin.mkdir()
        self.log = self.home / 'calls'
        for name, body in {
            'uname': 'echo Darwin',
            'brew': 'printf "%s\\n" "$*" >> "$CALL_LOG"',
            'sheldon': 'printf "sheldon %s\\n" "$*" >> "$CALL_LOG"',
            'launchctl': 'printf "launchctl %s\\n" "$*" >> "$CALL_LOG"',
            'defaults': 'printf "defaults %s\\n" "$*" >> "$CALL_LOG"',
            'git': 'echo "network disabled in test" >&2; exit 1',
            'curl': 'echo "network disabled in test" >&2; exit 1',
            'sleep': 'exit 0',
        }.items():
            p = self.bin / name
            p.write_text('#!/bin/bash\n' + body + '\n')
            p.chmod(0o755)
        self.env = {**os.environ, 'HOME': str(self.home), 'PATH': str(self.bin) + ':/usr/bin:/bin', 'CALL_LOG': str(self.log)}
        self.env.pop('DOTFILES_PROFILE', None)
    def tearDown(self):
        self.tmp.cleanup()
    def install(self, *args):
        return subprocess.run(['bash', str(ROOT/'scripts/install.sh'), *args], env=self.env, text=True, capture_output=True, timeout=10)
    def test_default_is_read_only(self):
        r = self.install()
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn('PLAN', r.stdout)
        self.assertFalse(self.log.exists())
        self.assertFalse((self.home/'.zshrc').exists())
    def test_invalid_feature_fails_before_changes(self):
        r = self.install('--apply', '--with', '../untrusted')
        self.assertNotEqual(r.returncode, 0)
        self.assertFalse(self.log.exists())
        self.assertFalse((self.home/'.zshrc').exists())
    def test_android_selection_only(self):
        r = self.install('--apply', '--with', 'android')
        self.assertEqual(r.returncode, 0, r.stderr)
        calls = self.log.read_text()
        self.assertIn('Brewfile.android', calls)
        self.assertNotIn('Brewfile.personal', calls)
        self.assertNotIn('launchctl', calls)
        self.assertNotIn('lock --update', calls)
        self.assertFalse((self.home/'.config/karabiner').exists())
    def link(self, src, target):
        return subprocess.run(['bash','-e','-c','source "$1"; create_symlink "$2" "$3"','test',str(ROOT/'scripts/lib/symlinks.sh'),str(src),str(target)], env=self.env, capture_output=True, text=True)
    def test_other_symlink_is_preserved(self):
        src=self.home/'source'; src.write_text('new')
        target=self.home/'target'; target.symlink_to('missing-old-path')
        r=self.link(src,target)
        self.assertEqual(r.returncode,0,r.stderr)
        backups=list(self.home.glob('target.backup.*'))
        self.assertEqual(len(backups),1)
        self.assertEqual(os.readlink(backups[0]),'missing-old-path')
    def test_missing_source_does_not_change_target(self):
        target=self.home/'target';target.write_text('keep')
        r=self.link(self.home/'missing',target)
        self.assertNotEqual(r.returncode,0)
        self.assertEqual(target.read_text(),'keep')
    def test_backup_collisions_and_idempotence(self):
        src=self.home/'source';src.write_text('new')
        target=self.home/'target';target.write_text('old')
        existing=self.home/'target.backup';existing.write_text('older')
        self.assertEqual(self.link(src,target).returncode,0)
        backups=list(self.home.glob('target.backup.*'))
        self.assertEqual(len(backups),1)
        self.assertEqual(backups[0].read_text(),'old')
        self.assertEqual(self.link(src,target).returncode,0)
        self.assertEqual(list(self.home.glob('target.backup.*')),backups)
        self.assertEqual(existing.read_text(),'older')
    def test_services_need_voice_before_changes(self):
        r=self.install('--apply','--services')
        self.assertNotEqual(r.returncode,0)
        self.assertFalse(self.log.exists())
    def test_shell_without_optional_tools(self):
        env={**self.env,'PATH':'/usr/bin:/bin','DOTFILES_ZSH':str(ROOT/'zsh')}
        r=subprocess.run(['zsh','-f','-c','source "$1"; print READY','test',str(ROOT/'zsh/.zshrc')],env=env,text=True,capture_output=True,timeout=15)
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertIn('READY',r.stdout)
        self.assertEqual(r.stderr,'')
    def test_insecure_secrets_are_not_executed(self):
        marker=self.home/'executed'
        secret=self.home/'.secrets';secret.write_text('touch "'+str(marker)+'"\n');secret.chmod(0o644)
        env={**self.env,'PATH':'/usr/bin:/bin','DOTFILES_ZSH':str(ROOT/'zsh')}
        subprocess.run(['zsh','-f','-c','source "$1"','test',str(ROOT/'zsh/.zshrc')],env=env,text=True,capture_output=True,timeout=15)
        self.assertFalse(marker.exists())
    def test_private_secrets_can_be_loaded(self):
        marker=self.home/'executed'
        secret=self.home/'.secrets';secret.write_text('touch "'+str(marker)+'"\n');secret.chmod(0o600)
        env={**self.env,'PATH':'/usr/bin:/bin','DOTFILES_ZSH':str(ROOT/'zsh')}
        r=subprocess.run(['zsh','-f','-c','source "$1"','test',str(ROOT/'zsh/.zshrc')],env=env,text=True,capture_output=True,timeout=15)
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertTrue(marker.exists())
    def test_repo_selection_cannot_execute_path_text(self):
        marker=self.home/'injected'
        selected=str(self.home/'repo with spaces')+'; touch '+str(marker)
        env={**self.env,'SELECTED':selected}
        script='ghq() { print -r -- "$SELECTED"; }; fzf() { cat; }; zle() { :; }; source "$1"; LBUFFER=""; ghq_fzf_repo; eval "$BUFFER"'
        subprocess.run(['zsh','-f','-c',script,'test',str(ROOT/'zsh/functions.zsh')],env=env,text=True,capture_output=True,timeout=15)
        self.assertFalse(marker.exists())

if __name__ == '__main__':
    unittest.main()
