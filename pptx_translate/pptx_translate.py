#!/usr/bin/python
#encoding=utf-8
from googletrans import Translator
import os
import tkinter.filedialog
import tkinter.messagebox
from pptx import Presentation

gtrans = Translator(service_urls=[
    'translate.google.cn'
])

print(gtrans.translate("Apple", src='en', dest='zh-cn'))

infile = ''
outfile = ''
prs = Presentation()

def do_translate(instr):
    tmp_save = False
    while(True):
        try:
            print("Going to translate"+instr)
            result = gtrans.translate(instr, src='en', dest='zh-cn')
            return result.text
        except TimeoutError:
            print("Google服务器连接失败，即将重试")
            if(not tmp_save):
                print("保存临时结果至"+outfile)
                save_output()
                tmp_save = True

def do_parse_and_translate_pptx():
    try:
        prs = Presentation(infile)
    except IOError:
        tkinter.messagebox.showerror('错误', "无法读取文件%s"%infile)
        exit(1)
    num_slides = len(prs.slides)
    for i in range(num_slides):
        slide = prs.slides[i]
        print("正在翻译第%0d/%0d页"%(i,num_slides))
        for shape in slide.shapes:
            if not shape.has_text_frame:
                continue
            for paragraph in shape.text_frame.paragraphs:
                for run in paragraph.runs:
                    run.text = do_translate(run.text)
    save_output()
    
def save_output():
    while(True):
        try:
            prs.save(outfile)
            tkinter.messagebox.showinfo("提示","翻译结果已经生成在%s"%outfile)
            break
        except IOError:
            retry = tkinter.messagebox.askretrycancel("错误", "写入%s失败，请关闭文档后重试"%outfile)
            if(retry==False):
                break

default_dir = os.getcwd()
infile = tkinter.filedialog.askopenfilename(title=u"选择文件", initialdir=(os.path.expanduser(default_dir)),
filetypes=[("PowerPoint","*.pptx")])
if(infile != ''):
    outfile = infile.replace(".pptx","_zh.pptx")
    yesno = tkinter.messagebox.askyesno("问题","是否使用\'%s\'作为输出文件名"%outfile)
    if(yesno == False):
        outfile = tkinter.filedialog.asksaveasfilename(title=u"请输入文件名", initialdir=(os.path.expanduser(default_dir)),
filetypes=[("PowerPointFile","*.pptx")], defaultextension=".pptx")
else:
    tkinter.messagebox.showerror("错误","未选择任何文件!")
    exit()
if(outfile == ''):
    tkinter.messagebox.showerror("错误", "未指定输出文件")
    exit()

do_parse_and_translate_pptx()

    