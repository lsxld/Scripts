#encoding=utf-8
import tkinter
from tkinter import ttk
from tkinter import *
import time
import random
from playsound import playsound
import os

class Typing(tkinter.Tk):
    def __init__(self):
        super().__init__()
        self.setup_UI()
        self.score = 0
        self.score_add = 10
        self.score_cut = 10
        self.speed = 0.0
        self.char_list = 'ASDFGHJKL;'
        self.curr_char = 'A'
        self.start_time = time.time()
        self.char_num = 0
        self.hide_char = False
        self.sound_path = '/Users/lsxld/Workspace/Scripts/Typing/sound'
        self.score_record_interval = 100
        self.score_target = 200

    def setup_UI(self):
        self.title("Typing Exercise")
        self.geometry("600x400+200+200")
        self.rowconfigure(0, weight=1)
        self.columnconfigure(0, weight=1)
        self.canvas = tkinter.Canvas(self)
        self.canvas.grid(row=0, column=0, sticky='nesw')
        self.canvas.configure(background='white')

        score_font = 'Calibri 15'
        char_font = 'Calibri 120 bold'
        self.score_id = self.canvas.create_text(60, 15, text="Score:      0", font=score_font)
        self.speed_id = self.canvas.create_text(600-60, 15, text="Speed:     0", font=score_font)

        self.start_button = tkinter.Button(text="开始", command=self.start)
        self.start_button.grid(row=0, column=0)
        self.char_id = self.canvas.create_text(300 , 200, text='', fill='black', font=char_font)
        os.system('say \"小睿睿, 我们来做个打字练习吧, 准备好了就按开始键\"')

    def start(self):
        self.start_button.grid_forget()
        self.canvas.itemconfigure(self.char_id, text='3')
        self.update()
        time.sleep(0.8)
        self.canvas.itemconfigure(self.char_id, text='2')
        self.update()
        time.sleep(0.8)
        self.canvas.itemconfigure(self.char_id, text='1')
        self.update()
        time.sleep(0.8)
        self.canvas.itemconfigure(self.char_id, text='Go!')
        self.update()
        time.sleep(1)
        self.char_num = 0
        self.canvas.focus_set()
        self.canvas.bind('<KeyPress>', self.check_char_func)
        self.canvas.bind('<KeyRelease>', self.next_char_func)
        self.start_time = time.time()
        if not self.hide_char:
            self.canvas.itemconfigure(self.char_id, text=self.curr_char)
        else:
            self.canvas.itemconfigure(self.char_id, text='')
        self.play_sound(self.curr_char)

    def check_char_func(self, event):
        if event.char.upper() == self.curr_char:
            self.canvas.itemconfigure(self.char_id, fill='green')
        else:
            self.canvas.itemconfigure(self.char_id, fill='red')

    def next_char_func(self, event):
        self.canvas.itemconfigure(self.char_id, fill='black')
        if event.char.upper() == self.curr_char:
            next_index = random.randint(0, len(self.char_list)-1)
            self.curr_char = self.char_list[next_index]
            if not self.hide_char:
                self.canvas.itemconfigure(self.char_id, text=self.curr_char)
            self.play_sound(self.curr_char)
            self.score = self.score + self.score_add
            self.char_num = self.char_num + 1
            curr_time = time.time()
            self.speed = self.char_num/(curr_time - self.start_time)*60
            if(self.score % self.score_record_interval == 0):
                print("Score: %5d Speed: %2.2f"%(self.score, self.speed))
            if(self.score >= self.score_target):
                self.score_eval()
        else:
            if self.score >= self.score_cut:
                self.score = self.score - self.score_cut
        self.redraw_score()

    def redraw_score(self):
        self.canvas.itemconfigure(self.score_id, text="Score: %5d"%self.score)
        self.canvas.itemconfigure(self.speed_id, text="Speed: %2.2f"%self.speed)

    def play_sound(self, char):
        playsound(f'{self.sound_path}/{char}.aac', False)

    def score_eval(self):
        final_score = 0
        eval_word = ''
        if self.speed >= 70:
            final_score = 100
            eval_word = '小睿睿, 你这次得了100分, 真是太棒棒啦'
        else:
            final_score = int(self.speed / 80 * 100)
            eval_word = f'小睿睿, 你这次得了{final_score}分, 继续加油哦'
        self.canvas.itemconfigure(self.char_id, text=f"{final_score}")
        self.update()
        print(eval_word)
        os.system(f'say \"{eval_word}\"')
        exit()


if __name__ == "__main__":
    typing = Typing()
    typing.mainloop()
