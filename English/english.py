#!/usr/bin/python
# _*_ coding:utf-8 _*_
import pyttsx3
import re
import random
import time
import os
import webbrowser
from googletrans import Translator

test_num = 10
db_path = '/Users/lsxld/Workspace/Scripts/English'
test_start = 'Hello Helen. Listen to {} words and type them down'.format(test_num)

engine = pyttsx3.init()
chn_voice = u'com.apple.speech.synthesis.voice.mei-jia'
eng_voice = u'com.apple.speech.synthesis.voice.Alex'

engine.setProperty('voice', chn_voice)
engine.setProperty('rate', 160)

gtrans = Translator(
    service_urls=['translate.google.cn'],
    proxies={
#        'https': '183.148.150.160:9999',
    })

words_list = list()
fail_db = dict()
f = open(db_path + "/test_words.db", 'r')
for line in f:
  line = line.rstrip()
  words_list.append(line)
f.close()
f = open(db_path + "/fail_words.db", 'r')
for line in f:
  line = line.strip()
  mobj = re.match(r'^(\d+)\s+(.+)$', line)
  if mobj:
    num = mobj.group(1)
    word = mobj.group(2)
    fail_db[word] = int(num)
  elif line != '':
    fail_db[line] = 1
f.close()

def say_word(word, chn=False):
  if chn:
    engine.setProperty('voice', chn_voice)
  else:
    engine.setProperty('voice', eng_voice)
  engine.say(word.decode('UTF-8'))
  engine.runAndWait()

print(test_start)
#say_word(test_start)
index_record = dict()
fail_word_list = list()
fail_history_list = fail_db.keys();
fail_num = 0
for i in range(test_num):
  if len(fail_history_list) == 0:
    index = random.randint(0, len(words_list)-1)
    while(index in index_record):
      index = random.randint(0, len(words_list)-1)
    index_record[index] = 1
    word = words_list[index]
  else:
    word = fail_history_list[0]
    del fail_history_list[0]
  #chn_word = gtrans.translate(word, src='en', dest='zh-cn').text.encode('UTF-8')
  chn_word = 'abc'
  say_word('Number {}'.format(i+1))
  print('No.{} 输入听到的句子, 输入0回车 提示中文:'.format(i+1))
  say_word(word)
  start_time = time.time()
  inp = raw_input()
  fail = False
  if inp != word:
    print("提示: "+chn_word)
    say_word(chn_word, chn=True)
  while inp != word:
#    if inp == 'a': break
    if inp != '' and (inp[0].upper() == word[0].upper() or inp.upper() == word.upper()):
      say_word("注意句子第一个字母和名字的第一个字母都要大写", chn=True)
    if inp == '0':
      print(word)
      say_word(word)
      fail = True
#    elif inp == '1':
#      imgurl = 'https://www.google.com/search?tbm=isch&q='+word.replace(' ', '+')
#      #imgurl = 'https://www.kiddle.co/i.php?q='+word.replace(' ', '+')
#      webbrowser.open_new(imgurl)
#      fail = True
    else:
      say_word(word)
    inp = raw_input()
  if fail:
    fail_num = fail_num + 1
    fail_word_list.append(word)
    if word in fail_db:
      fail_db[word] = fail_db[word] + 1
    else:
      fail_db[word] = 1
  else:
    if word in fail_db:
      fail_db[word] = fail_db[word] - 1
      if fail_db[word] == 0:
        del fail_db[word]
  end_time = time.time()
  print('Cost {} seconds'.format(int(end_time-start_time+1)))
f = open(db_path + "/fail_words.db", 'w')
for key,value in fail_db.items():
  f.write('{} {}\n'.format(value, key))
f.close()
test_last = "Well done, Helen! You finished! Today, you have {} words failed.".format(fail_num)
print("Failed number: {}".format(fail_num))
for c in fail_word_list:
  print("Failed word: "+c)
say_word(test_last)
