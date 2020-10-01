#!python3
#encoding=utf-8
import time
import tkinter
from tkinter import ttk

class Typing(tkinter.Tk):
  def __init__(self):
    super().__init__()
    self.setup_UI()
    self.score = 0
    self.cpm = 0.0
    self.start_time = 0
    self.curr_time = 0

  def setup_UI(self):
    self.title("Typing Exercise")
    self.geometry("640x500+250+250")
    self.rowconfigure(0, weight=1)
    self.columnconfigure(0, weight=1)
    self.resizable(False, False)
    self.canvas = tkinter.Canvas(self)
    self.canvas.grid(row=0, column=0, sticky='nesw')

    

if __name__ == '__main__':
  typing = Typing()
  typing.mainloop()
