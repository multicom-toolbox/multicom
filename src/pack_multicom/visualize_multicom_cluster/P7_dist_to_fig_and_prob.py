# -*- coding: utf-8 -*-
"""
Created on Tue Jan 19 17:27:04 2021

@author: Jian Liu
"""
import os
import sys
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

if len(sys.argv) == 5:
    targetname = str(sys.argv[1])
    contact_txt = str(sys.argv[2])
    dist_txt = str(sys.argv[3])
    output_dir = str(sys.argv[4])
else:
    print('1:Input contact txt, 2:Output dir')
    sys.exit(1)  

def Transform_rr_to_marix(input_txt):
    with open(input_txt, 'r') as fp_in:
        line = fp_in.readline()
        while line:
            tmp = line.replace('\n', '').split(' ')
            if len(tmp) == 1 and tmp[0] != 'END':
                seq = tmp[0]
                L = len(tmp[0])
                rr_matrix = np.eye(L)
            elif len(tmp) == 5:
                row = int(tmp[0]) - 1
                col = int(tmp[1]) - 1
                prob = float(tmp[4])
                rr_matrix[row, col] = prob
                rr_matrix[col, row] = prob

            line = fp_in.readline()

    #np.savetxt(output_rr, rr_matrix, fmt='%.05f')
    return rr_matrix


def get_range_top_of_contact_map(input_map, range = 'long', top = 'l2'):
    length = input_map.shape[0]
    map_copy = np.copy(input_map)
    if range == 'long':
        map_copy = np.triu(map_copy, 23)
    elif range == 'medium':
        map_copy = np.triu(map_copy, 11) - np.triu(map_copy, 23)

    map_copy = map_copy.flatten()
    if top == 'l2':
        map_copy[map_copy.argsort()[::-1][0:int(length/2)]] = 1
        map_copy[map_copy < 1] = 0
    elif top == 'l5':
        map_copy[map_copy.argsort()[::-1][0:int(length/5)]] = 1
        map_copy[map_copy < 1] = 0
    elif top == 'l':
        map_copy[map_copy.argsort()[::-1][0:int(length)]] = 1
        map_copy[map_copy < 1] = 0
    map_copy = map_copy.reshape(length, length)
    return map_copy

def generate_prec_txt(cmap, output_txt):

    topl2 = get_range_top_of_contact_map(cmap, 'long', 'l2')
    number_of_topl2 = np.sum(topl2)
    sum_prob_of_topl2 = np.sum(cmap*topl2)
    avg_prob_l2 = sum_prob_of_topl2/number_of_topl2

    topl5 = get_range_top_of_contact_map(cmap, 'long', 'l5')
    number_of_topl5 = np.sum(topl5)
    sum_prob_of_topl5 = np.sum(cmap*topl5)
    avg_prob_l5 = sum_prob_of_topl5/number_of_topl5

    topl2_prec = 101.54 * avg_prob_l2 + 2.5846
    topl5_prec = 95.597 * avg_prob_l5 + 3.5845

    with open(output_txt, 'w') as fp_out:
        fp_out.writelines("Long-Range\tAverage_Probability\tPredicted_Precision\n")
        fp_out.writelines("TopL/5\t%.2f\t%.2f\n"%(avg_prob_l5,topl5_prec))
        fp_out.writelines("TopL/2\t%.2f\t%.2f\n"%(avg_prob_l2,topl2_prec))

def generate_dist_contact_fig(dist_matrix, cmap, outputdir):
    dmap_img = outputdir + '/' + targetname + '_d.jpg'
    cmap_img = outputdir + '/' + targetname + '_c.jpg'

    print("Save dist map to %s" % dmap_img)
    plt.axis('off')
    plt.gca().xaxis.set_major_locator(plt.NullLocator())
    plt.gca().yaxis.set_major_locator(plt.NullLocator())
    plt.subplots_adjust(top=1, bottom=0, left=0, right=1, hspace=0, wspace=0)
    plt.margins(0, 0)

    dist_from_mulclass = np.loadtxt(dist_matrix)
    plt.imshow(dist_from_mulclass)
    plt.savefig(dmap_img, bbox_inches='tight', dpi=700, pad_inches=0.0)
    plt.close()

    cmap_copy1 = np.copy(cmap)
    cmap_copy1[cmap_copy1 > 0.5] = 1
    cmap_copy1[cmap_copy1 <= 0.5] = 0

    print("Save contact map to %s" % cmap_img)
    plt.axis('off')
    plt.gca().xaxis.set_major_locator(plt.NullLocator())
    plt.gca().yaxis.set_major_locator(plt.NullLocator())
    plt.subplots_adjust(top=1, bottom=0, left=0, right=1, hspace=0, wspace=0)
    plt.margins(0, 0)

    plt.imshow(cmap_copy1, cmap=plt.cm.gray_r)
    plt.savefig(cmap_img, bbox_inches='tight', dpi=700, pad_inches=0.0)


rr_matrix = Transform_rr_to_marix(contact_txt)

generate_prec_txt(rr_matrix, output_dir + '/' + targetname + '_prec.txt')

generate_dist_contact_fig(dist_txt, rr_matrix, output_dir)
