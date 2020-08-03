#!/usr/bin/python
# _*_ coding:utf-8 _*_
import pyttsx3
import re
import random
import time
from pypinyin import pinyin
import os
import webbrowser

test_num = 30
repeat_times = 2
test_start = '小睿睿，我们来默写{}个字吧'.format(test_num)

engine = pyttsx3.init()

char_db = dict()
char_list = list()
f = open("/Users/lsxld/Workspace/Scripts/Chinese/test_char.db", 'r')
for line in f:
  line = line.rstrip()
  mobj = re.search(r'\((.+)\)', line)
  if mobj:
    char = mobj.group(1)
    word = line
    word = word.replace('(', '')
    word = word.replace(')', '')
    char_db[char] = word
    char_list.append(char)
f.close()

def say_word(word):
  engine.say(word.decode('UTF-8'))
  engine.runAndWait()

def test_char(char):
  show_word = char_db[char]
  char_pinyin = pinyin(char.decode('UTF-8'))[0][0].encode('UTF-8')
  show_word = show_word.replace(char, '(' + char_pinyin + ')')
  print(show_word)
  for r in range(repeat_times):
    say_word(char_db[char]+ '的'+ char)

import urllib2

def show_char_gif(char):
  url='http://hanyu.baidu.com/s?wd='+urllib2.quote(char)+'&ptype=zici'
  header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.119 Safari/537.36'
  }
  request = urllib2.Request(url, headers=header)
  reponse = urllib2.urlopen(request).read()
  html = str(reponse)
  mobj = re.search(r'data-gif="(.+\.gif)"', html)
  imageurl=mobj.group(1)
  webbrowser.open_new(imageurl)
#  imagename = char + '.gif'
#  with open(imagename, 'wb') as f:
#    f.write(urllib2.urlopen(imageurl).read())
#  os.system('open ' + imagename)
  

print(test_start)
say_word(test_start)
index_record = dict()
for i in range(test_num):
  print('{}. '.format(i + 1)),
  say_word('第{}个'.format(i+1))
  index = random.randint(0, len(char_db)-1)
  while(index in index_record):
    index = random.randint(0, len(char_db)-1)
  index_record[index] = 1
  char = char_list[index]
  test_char(char)
  start_time = time.time()
  inp = raw_input("写完按回车，不会的话输入0，然后回车，获得提示:")
  if inp == '0':
    print("提示: "+char_db[char])
    show_char_gif(char)
    raw_input('按回车继续')
  end_time = time.time()
  print('这题用了{}秒'.format(int(end_time-start_time+1)))
