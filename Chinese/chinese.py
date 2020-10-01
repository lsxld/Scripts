#!/usr/bin/python
# _*_ coding:utf-8 _*_
import pyttsx3
import re
import random
import time
from pypinyin import pinyin
import os
import webbrowser
import urllib2

test_num = 30
repeat_times = 2
auto_word_num = 3
db_path = '/Users/lsxld/Workspace/Scripts/Chinese'
test_start = '小睿睿，我们来默写{}个字吧'.format(test_num)

engine = pyttsx3.init()
print(engine.getProperty('voice'))

char_db = dict()
char_list = list()
fail_db = dict()
f = open(db_path + "/test_char.db", 'r')
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
f = open(db_path + "/fail_char.db", 'r')
for line in f:
  line = line.strip()
  mobj = re.search(r'(.+)\s+(\d+)', line)
  if mobj:
    char = mobj.group(1)
    num = mobj.group(2)
    fail_db[char] = int(num)
  elif line != '':
    fail_db[line] = 1
f.close()

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

def auto_find_word(char):
  url='http://hanyu.baidu.com/s?wd='+urllib2.quote(char)+'&ptype=zici'
  header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.119 Safari/537.36'
  }
  request = urllib2.Request(url, headers=header)
  reponse = urllib2.urlopen(request).read()
  html = str(reponse)
  word_list = list()
  for mobj in re.finditer(r'<a href="\?wd=(.+)&cf=zuci&ptype=term">', html):
    if mobj.group(1) != char + '组词':
      word_list.append(mobj.group(1))
  return word_list

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
  if auto_word_num > 0:
    word_list = auto_find_word(char)
    show_word = '其他词语: '
    say = '其他词语还有:'
    num = 0
    for word in word_list:
      show_word = show_word + word + ', '
      if num <= auto_word_num:
        say = say + word + ','
        num = num + 1
    say = say.rstrip(', ')
    say = say + '等'
    show_word = show_word.replace(char, '( )')
    print(show_word)
    say_word(say)

      
      


print(test_start)
say_word(test_start)
index_record = dict()
fail_char_list = list()
fail_history_list = fail_db.keys();
test_char_list = list()
hint_num = 0
for i in range(test_num):
  print('{}. '.format(i + 1)),
  say_word('第{}个'.format(i+1))
  if len(fail_history_list) == 0:
    index = random.randint(0, len(char_db)-1)
    while(index in index_record):
      index = random.randint(0, len(char_db)-1)
    index_record[index] = 1
    char = char_list[index]
  else:
    char = fail_history_list[0]
    del fail_history_list[0]
  test_char(char)
  test_char_list.append(char)
  start_time = time.time()
  inp = raw_input("写完按回车，不会的话输入0，然后回车，获得提示:")
  if inp == '0':
    if char in fail_db:
      fail_db[char] = fail_db[char] + 2
    else:
      fail_db[char] = 3
    hint_num = hint_num + 1
    fail_char_list.append(char)
    show_char_gif(char)
    raw_input('按回车继续')
  elif char in fail_db:
    if fail_db[char] == 1:
      del fail_db[char]
    else:
      fail_db[char] = fail_db[char] - 1
  end_time = time.time()
  print('这题用了{}秒'.format(int(end_time-start_time+1)))
f = open(db_path + "/fail_char.db", 'w')
for key,value in fail_db.items():
  f.write('{} {}\n'.format(key, value))
f.close()
test_last = "小睿睿, 祝贺你, 默写完成啦, 这次你有{}个字不会写, 继续加油啊!".format(hint_num)
print("提示次数: {}".format(hint_num))
for c in fail_char_list:
  print("提示的字: "+c)
for i,c in enumerate(test_char_list):
  if((i+1) % 5 == 0):
    print(c)
  else:
    print("{} ".format(c)),
say_word(test_last)
