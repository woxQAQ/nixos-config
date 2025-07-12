#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Git历史记录统计工具
显示每次提交的新增和删除行数，以美观的形式展示
只使用Python标准库，无需安装第三方依赖
"""

import subprocess
import re
import sys
import os
from dataclasses import dataclass
from enum import Enum

# ANSI颜色代码
class Colors(Enum):
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    BOLD = '\033[1m'
    RESET = '\033[0m'

@dataclass
class CommitInfo:
    hash: str
    author: str
    date: str
    message: str
    insertions: int
    deletions: int
    files_changed: int

class GitStatsAnalyzer:
    def __init__(self):
        # 检测是否支持颜色输出
        self.use_colors = self._supports_color()

    def _supports_color(self) -> bool:
        """检测终端是否支持颜色"""
        return (
            hasattr(sys.stdout, 'isatty') and sys.stdout.isatty() and
            os.environ.get('TERM') != 'dumb'
        )

    def combine_colors(self, *colors: Colors) -> str:
        """组合多个颜色代码"""
        return ''.join(color.value for color in colors)

    def colorize(self, text: str, color: Colors) -> str:
        """为文本添加颜色"""
        if not self.use_colors:
            return text
        return f"{color.value}{text}{Colors.RESET.value}"

    def colorize_multi(self, text: str, *colors: Colors) -> str:
        """为文本添加多个颜色"""
        if not self.use_colors:
            return text
        color_codes = self.combine_colors(*colors)
        return f"{color_codes}{text}{Colors.RESET.value}"

    def run_git_command(self, cmd, raise_on_error=True) -> str:
        """执行git命令"""
        try:
            if isinstance(cmd, str):
                cmd = cmd.split()
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True,
                cwd='.'
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError as e:
            if raise_on_error:
                raise
            print(self.colorize(f"Git命令执行失败: {e}", Colors.RED))
            sys.exit(1)
        except FileNotFoundError:
            print(self.colorize("Git未找到，请确保已安装Git", Colors.RED))
            sys.exit(1)

    def parse_commit_stats(self, commit_hash: str) -> tuple:
        """获取单个提交的统计信息"""
        try:
            # 获取提交的详细统计
            stats_cmd = ["git", "show", "--stat", "--format=", commit_hash]
            stats_output = self.run_git_command(stats_cmd)

            # 解析统计信息
            insertions = deletions = files_changed = 0

            for line in stats_output.split('\n'):
                if 'insertions' in line or 'deletions' in line or 'files changed' in line:
                    # 匹配类似 "5 files changed, 123 insertions(+), 45 deletions(-)"
                    numbers = re.findall(r'(\d+)', line)
                    if numbers:
                        if 'files changed' in line:
                            files_changed = int(numbers[0])
                        if 'insertions' in line:
                            # 查找insertions前的数字
                            insertion_match = re.search(r'(\d+) insertions?', line)
                            if insertion_match:
                                insertions = int(insertion_match.group(1))
                        if 'deletions' in line:
                            # 查找deletions前的数字
                            deletion_match = re.search(r'(\d+) deletions?', line)
                            if deletion_match:
                                deletions = int(deletion_match.group(1))

            return insertions, deletions, files_changed

        except Exception:
            return 0, 0, 0

    def show_progress(self, current: int, total: int, text: str = "处理中"):
        """显示进度条"""
        if total == 0:
            return

        percent = int((current / total) * 100)
        bar_length = 30
        filled_length = int(bar_length * current / total)

        if self.use_colors:
            # 使用颜色的进度条
            colored_text = self.colorize(text, Colors.CYAN)
            filled_bar = self.colorize('█' * filled_length, Colors.GREEN)
            empty_bar = self.colorize('-' * (bar_length - filled_length), Colors.WHITE)
            colored_percent = self.colorize(f"{percent}%", Colors.YELLOW)
            progress_text = f"\r{colored_text} [{filled_bar}{empty_bar}] {colored_percent} ({current}/{total})"
        else:
            # 无颜色的进度条
            bar = '█' * filled_length + '-' * (bar_length - filled_length)
            progress_text = f"\r{text} [{bar}] {percent}% ({current}/{total})"

        print(progress_text, end='', flush=True)

    def get_commit_history(self, limit: int = 50) -> list[CommitInfo]:
        """获取git提交历史"""
        # 获取提交历史的基本信息
        cmd = ["git", "log", "--oneline", "--format=%H|%an|%ad|%s", "--date=short", "-n", str(limit)]
        output = self.run_git_command(cmd)

        commits = []
        lines = [line for line in output.split('\n') if line.strip()]

        print(self.colorize("\n分析提交记录...", Colors.CYAN))

        for i, line in enumerate(lines, 1):
            self.show_progress(i, len(lines), "分析提交记录")

            parts = line.split('|', 3)
            if len(parts) != 4:
                continue

            hash_val, author, date, message = parts

            # 获取此提交的统计信息
            insertions, deletions, files_changed = self.parse_commit_stats(hash_val)

            commit = CommitInfo(
                hash=hash_val[:8],
                author=author,
                date=date,
                message=message,
                insertions=insertions,
                deletions=deletions,
                files_changed=files_changed
            )
            commits.append(commit)

        print()  # 换行
        return commits

    def get_display_width(self, text: str) -> int:
        """计算文本的显示宽度（考虑中文字符）"""
        width = 0
        # 移除ANSI颜色代码
        clean_text = re.sub(r'\033\[[0-9;]*m', '', text)
        for char in clean_text:
            # 中文字符宽度为2，其他字符宽度为1
            if '\u4e00' <= char <= '\u9fff':  # 中文字符范围
                width += 2
            else:
                width += 1
        return width

    def print_table(self, commits: list[CommitInfo]):
        """打印统计表格"""
        # 表格标题
        title = "Git 提交历史统计"
        print(f"\n{self.colorize_multi(title.center(100, '='), Colors.BOLD, Colors.MAGENTA)}\n")

        # 表头
        headers = ["提交哈希", "作者", "日期", "新增", "删除", "文件数", "提交信息"]
        widths = [10, 15, 12, 8, 8, 8, 40]

        # 计算表格总宽度
        total_width = sum(widths) + len(headers) * 3 - 1

        # 打印表头
        print("┌" + "─" * total_width + "┐")

        header_line = "│"
        for i, (header, width) in enumerate(zip(headers, widths)):
            header_width = self.get_display_width(header)
            padding = width - header_width
            left_pad = padding // 2
            right_pad = padding - left_pad

            if self.use_colors:
                colored_header = self.colorize_multi(header, Colors.BOLD, Colors.CYAN)
                header_line += f" {' ' * left_pad}{colored_header}{' ' * right_pad} │"
            else:
                header_line += f" {' ' * left_pad}{header}{' ' * right_pad} │"
        print(header_line)

        # 分隔线
        separator_line = "├"
        for i, width in enumerate(widths):
            separator_line += "─" * (width + 2) + ("┼" if i < len(widths) - 1 else "┤")
        print(separator_line)

        # 打印数据行
        for commit in commits:
            row_data = [
                commit.hash,
                commit.author[:14] + ("…" if len(commit.author) > 14 else ""),
                commit.date,
                str(commit.insertions) if commit.insertions > 0 else "-",
                str(commit.deletions) if commit.deletions > 0 else "-",
                str(commit.files_changed) if commit.files_changed > 0 else "-",
                commit.message[:38] + "…" if len(commit.message) > 38 else commit.message
            ]

            row_line = "│"
            for i, (data, width) in enumerate(zip(row_data, widths)):
                # 处理特殊列的前缀
                display_data = data
                if i == 3 and commit.insertions > 0:  # 新增列
                    display_data = f"+{data}"
                elif i == 4 and commit.deletions > 0:  # 删除列
                    display_data = f"-{data}"

                # 计算实际显示宽度
                data_width = self.get_display_width(display_data)
                padding = width - data_width

                # 添加颜色
                if i == 3 and commit.insertions > 0:  # 新增列
                    colored_data = self.colorize(display_data, Colors.GREEN)
                elif i == 4 and commit.deletions > 0:  # 删除列
                    colored_data = self.colorize(display_data, Colors.RED)
                elif i == 1:  # 作者列
                    colored_data = self.colorize(data, Colors.GREEN)
                elif i == 2:  # 日期列
                    colored_data = self.colorize(data, Colors.BLUE)
                elif i == 5:  # 文件数列
                    colored_data = self.colorize(data, Colors.YELLOW)
                else:
                    colored_data = data

                if i in [3, 4, 5]:  # 右对齐的列
                    row_line += f" {' ' * padding}{colored_data} │"
                else:  # 左对齐的列
                    row_line += f" {colored_data}{' ' * padding} │"

            print(row_line)

        print("└" + "─" * total_width + "┘")

    def print_summary(self, commits: list[CommitInfo]):
        """打印汇总信息"""
        total_commits = len(commits)
        total_insertions = sum(c.insertions for c in commits)
        total_deletions = sum(c.deletions for c in commits)
        total_files = sum(c.files_changed for c in commits)
        net_change = total_insertions - total_deletions

        # 统计作者
        authors = {}
        for commit in commits:
            authors[commit.author] = authors.get(commit.author, 0) + 1

        most_active_author = max(authors.items(), key=lambda x: x[1]) if authors else ("无", 0)

        # 创建汇总框
        summary_title = "📊 统计摘要"
        box_width = 60

        # 计算标题居中
        title_width = self.get_display_width(summary_title)
        title_padding = box_width - title_width
        title_left = title_padding // 2
        title_right = title_padding - title_left

        print(f"\n{'=' * title_left}{self.colorize_multi(summary_title, Colors.BOLD, Colors.GREEN)}{'=' * title_right}")
        print("┌" + "─" * (box_width - 2) + "┐")

        summary_items = [
            ("总提交数", f"{total_commits}", Colors.CYAN),
            ("总新增行数", f"+{total_insertions}", Colors.GREEN),
            ("总删除行数", f"-{total_deletions}", Colors.RED),
            ("净变化", f"{net_change:+}", Colors.GREEN if net_change >= 0 else Colors.RED),
            ("涉及文件数", f"{total_files}", Colors.YELLOW),
            ("最活跃作者", f"{most_active_author[0]} ({most_active_author[1]}次)", Colors.MAGENTA)
        ]

        for label, value, color in summary_items:
            # 计算行内容的实际显示宽度（不包含边框）
            prefix = "• "
            separator = ": "
            content_width = self.get_display_width(prefix + label + separator + value)
            padding = box_width - content_width - 2  # 减去左右边框的2个字符

            # 创建带颜色的值
            value_colored = self.colorize(value, color)
            print(f"│{prefix}{label}{separator}{value_colored}{' ' * padding}│")

        print("└" + "─" * (box_width - 2) + "┘")

    def display_stats(self, limit: int = 50):
        """显示git统计信息"""
        title = "🔍 Git 历史记录分析工具"
        print(f"\n{self.colorize_multi(title, Colors.BOLD, Colors.GREEN)}\n")

        # 检查是否在git仓库中
        try:
            self.run_git_command(["git", "rev-parse", "--git-dir"])
        except subprocess.CalledProcessError:
            print(self.colorize("❌ 当前目录不是git仓库", Colors.RED))
            return
        except Exception as e:
            print(self.colorize(f"Git检查失败: {e}", Colors.RED))
            return

        # 获取提交历史
        commits = self.get_commit_history(limit)

        if not commits:
            print(self.colorize("⚠️  未找到提交记录", Colors.YELLOW))
            return

        # 显示汇总信息
        self.print_summary(commits)

        # 显示详细表格
        self.print_table(commits)

def main():
    import argparse

    parser = argparse.ArgumentParser(description="分析Git历史记录的新增和删除统计")
    parser.add_argument("-n", "--limit", type=int, default=50,
                       help="显示的提交数量 (默认: 50)")
    parser.add_argument("--no-color", action="store_true",
                       help="禁用颜色输出")

    args = parser.parse_args()

    analyzer = GitStatsAnalyzer()
    if args.no_color:
        analyzer.use_colors = False

    analyzer.display_stats(args.limit)

if __name__ == "__main__":
    main()
