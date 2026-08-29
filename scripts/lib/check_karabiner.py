#!/usr/bin/env python3
"""karabiner.json の構造検査。

JSON として読めるだけでは足りない。profiles が空だったり manipulators の無い
rule が混ざっていると、Karabiner-Elements は起動してもキーリマップが効かない。
新しいマシンでキーボードが死ぬのを防ぐための最低限の検査。
"""

import json
import sys


def check(path: str) -> list[str]:
    errors: list[str] = []

    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    profiles = data.get("profiles")
    if not isinstance(profiles, list) or not profiles:
        return ["profiles が空、または配列ではありません"]

    if not any(p.get("selected") for p in profiles):
        errors.append("selected なプロファイルがありません")

    rule_count = 0
    for profile in profiles:
        name = profile.get("name", "(名前なし)")

        for mod in profile.get("simple_modifications", []):
            if not mod.get("from") or not mod.get("to"):
                errors.append(f"[{name}] simple_modifications に from/to の欠けがあります: {mod}")

        rules = profile.get("complex_modifications", {}).get("rules", [])
        rule_count += len(rules)
        for rule in rules:
            desc = rule.get("description", "(説明なし)")
            manipulators = rule.get("manipulators")
            if not manipulators:
                errors.append(f"[{name}] manipulators の無い rule: {desc}")
                continue
            for m in manipulators:
                if not m.get("type"):
                    errors.append(f"[{name}] type の無い manipulator: {desc}")
                if not m.get("from"):
                    errors.append(f"[{name}] from の無い manipulator: {desc}")

    print(f"       プロファイル {len(profiles)} 件 / 複雑ルール {rule_count} 件")
    return errors


if __name__ == "__main__":
    problems = check(sys.argv[1])
    for problem in problems:
        print(f"       {problem}", file=sys.stderr)
    sys.exit(1 if problems else 0)
