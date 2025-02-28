import os
import sys
import markdown
from weasyprint import HTML

def merge_markdown_files(directory, output_file):
    # 获取目录下所有 .zh_CN.md 文件
    files = [f for f in os.listdir(directory) if f.endswith('.zh_CN.md')]
    files.sort()  # 按文件名排序

    # 合并文件内容
    merged_content = ""
    for file in files:
        with open(os.path.join(directory, file), 'r', encoding='utf-8') as f:
            merged_content += f.read() + "\n\n"  # 添加两个换行符以分隔不同的文件内容

    # 将合并后的内容写入输出文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(merged_content)

def convert_markdown_to_pdf(input_file, output_file, version, translators_file):
    # 读取作者信息
    with open(translators_file, 'r', encoding='utf-8') as f:
        authors = f.readlines()
    authors = [author.strip() for author in authors if author.strip()]  # 去除空白行和多余空格
    authors_str = ", ".join(authors)  # 将作者列表合并为一个字符串

    # 使用 markdown 库将 Markdown 文件转换为 HTML
    with open(input_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
    
    # 使用 markdown 的 extra 扩展来处理代码块
    html_content = markdown.markdown(md_content, extensions=['extra'])

    # 添加CSS样式来设置代码块的背景颜色为淡淡的灰色，并根据行数调整字号
    html_content = f"""
    <style>
        pre, code {{ background-color: #e0e0e0; padding: 10px; border-radius: 5px; font-size: 1em; line-height: 1.4; display: flex; align-items: center; }}
        pre.multiline, code.multiline {{ font-size: 0.9em; line-height: 1.4; display: flex; align-items: center; }}
        a {{ text-decoration: none; }}  // 添加这一行以取消链接的下划线
    </style>
    """ + html_content

    # 添加标题、版本和译者信息
    html_content = f"<h1>PICO-8 中文手册</h1><h2>{version}</h2><h3>译者: {authors_str}</h3>\nPICO-8 像素炸弹！爱好者交流群：143554779\n" + html_content

    # 修改代码块以添加 multiline 类
    from bs4 import BeautifulSoup
    soup = BeautifulSoup(html_content, 'html.parser')
    for code in soup.find_all('code'):
        if code.parent.name == 'pre' and code.text.count('\n') > 0:
            code['class'] = 'multiline'
            code.parent['class'] = 'multiline'
    html_content = str(soup)

    # 使用 weasyprint 库将 HTML 内容转换为 PDF 文件
    HTML(string=html_content).write_pdf(output_file)

if __name__ == "__main__":
    directory = sys.argv[1]
    version = sys.argv[2]
    output_directory = sys.argv[3]
    merged_md_file = "{}/.merged_manual.md".format(output_directory)
    pdf_file = "{}/pico8手册{}.pdf".format(output_directory, version)

    merge_markdown_files(directory + "/sections", merged_md_file)
    convert_markdown_to_pdf(merged_md_file, pdf_file, version, "{}/translators.txt".format(directory))
    os.remove(merged_md_file)