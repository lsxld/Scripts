# -*- coding: utf-8 -*-
import os
import re

icloud_photo_path = 'C:\\Users\\刘世旭\\Pictures\\iCloud Photos\\Downloads'
dupl_file_dict = dict()
for(dirpath, dirnames, filenames) in os.walk(icloud_photo_path):
    for fn in filenames:
        fullname = os.path.join(dirpath, fn)
        if fullname in dupl_file_dict:
            continue
        else:
            obj = re.match('^([^\(（\.]+)', fn)
            if obj:
                prefix = obj.group(1)
                file_list = []
                file_list.append(os.path.join(dirpath, f'{prefix}(Edited).jpg'))
                file_list.append(os.path.join(dirpath, f'{prefix} （已编辑）.jpg'))
                file_list.append(os.path.join(dirpath, f'{prefix}(Edited).heic'))
                file_list.append(os.path.join(dirpath, f'{prefix} （已编辑）.heic'))
                file_list.append(os.path.join(dirpath, f'{prefix}.jpg'))
                file_list.append(os.path.join(dirpath, f'{prefix}.heic'))
                i = 0
                for i in range(len(file_list)):
                    if os.path.exists(file_list[i]):
                        break
                if(i+1 < len(file_list)):
                    for j in range(i+1, len(file_list)):
                        if os.path.exists(file_list[j]):
                            dupl_file_dict[file_list[j]] = 1
                mov_file = os.path.join(dirpath, f'{prefix}.mov')
                mov_hevc = os.path.join(dirpath, f'{prefix}_HEVC.mov')
                if(os.path.exists(mov_file) and os.path.exists(mov_hevc)):
                    dupl_file_dict[mov_hevc] = 1

for dupl_file in dupl_file_dict:
    print(dupl_file)
    os.remove(dupl_file)