# -*- coding: utf-8 -*-
"""
Created on Fri March 6 15:55:26 2020

@author: Zhiye
"""
import os
import sys
import cv2
import math
import argparse
import subprocess
import numpy as np
import scipy.stats as stats
from sklearn.metrics import precision_score
from utils_gist import *
from utils_tool import *

def is_dir(dirname):
    """Checks if a path is an actual directory"""
    if not os.path.isdir(dirname):
        msg = "{0} is not a directory".format(dirname)
        raise argparse.ArgumentTypeError(msg)
    else:
        return dirname

def is_file(filename):
    """Checks if a file is an invalid file"""
    if not os.path.exists(filename):
        msg = "{0} doesn't exist".format(filename)
        raise argparse.ArgumentTypeError(msg)
    else:
        return filename

def chkdirs(fn):
    '''create folder if not exists'''
    dn = os.path.dirname(fn)
    if not os.path.exists(dn): os.makedirs(dn)


def psnr(target, ref):
    target_data = np.array(target)
    ref_data = np.array(ref)
    diff = ref_data - target_data
    diff = diff.flatten('C')
    rmse = math.sqrt(np.mean(diff ** 2.))
    return 20 * math.log10(1.0 / (rmse+1e-10))

def floor_lower_left_to_zero(XP, min_seq_sep):
  X = np.copy(XP)
  L = int(math.sqrt(len(X)))
  X_reshaped = X.reshape(L, L)
  for p in range(0,L):
    for q in range(0,L):
      if ( q - p < min_seq_sep):
        X_reshaped[p, q] = 0
  X = X_reshaped.reshape(L * L)
  return X

def ssim(img1, img2):
    C1 = (0.01 * 255)**2
    C2 = (0.03 * 255)**2

    img1 = img1.astype(np.float64)
    img2 = img2.astype(np.float64)
    kernel = cv2.getGaussianKernel(11, 1.5)
    window = np.outer(kernel, kernel.transpose())

    mu1 = cv2.filter2D(img1, -1, window)[5:-5, 5:-5]  # valid
    mu2 = cv2.filter2D(img2, -1, window)[5:-5, 5:-5]
    mu1_sq = mu1**2
    mu2_sq = mu2**2
    mu1_mu2 = mu1 * mu2
    sigma1_sq = cv2.filter2D(img1**2, -1, window)[5:-5, 5:-5] - mu1_sq
    sigma2_sq = cv2.filter2D(img2**2, -1, window)[5:-5, 5:-5] - mu2_sq
    sigma12 = cv2.filter2D(img1 * img2, -1, window)[5:-5, 5:-5] - mu1_mu2

    ssim_map = ((2 * mu1_mu2 + C1) * (2 * sigma12 + C2)) / ((mu1_sq + mu2_sq + C1) * (sigma1_sq + sigma2_sq + C2))
    return ssim_map.mean()

def calc_ssim(img1, img2):
    '''calculate SSIM
    img1, img2: [0, 255]
    '''
    if not img1.shape == img2.shape:
        raise ValueError('Input images must have the same dimensions.')
    if img1.ndim == 2:
        return ssim(img1, img2)
    elif img1.ndim == 3:
        if img1.shape[2] == 3:
            ssims = []
            for i in range(3):
                ssims.append(ssim(img1, img2))
            return np.array(ssims).mean()
        elif img1.shape[2] == 1:
            return ssim(np.squeeze(img1), np.squeeze(img2))
    else:
        raise ValueError('Wrong input image dimensions.')

def combine_tbdist_into_abdist(tb_dist, ab_dist):
    violate_count = 0
    length = ab_dist.shape[0]
    tb_dist_bool = np.logical_and(tb_dist<=15, tb_dist>=4)
    ab_dist_bool = ab_dist >= 15
    overlap = np.logical_and(tb_dist_bool, ab_dist_bool)
    overlap = np.triu(overlap, 6) + np.tril(overlap, -6)
    # break
    tb_dist_raw = tb_dist * overlap
    ab_dist_raw = ab_dist * (ab_dist < 15)
    #rank tb_dist_raw 1.dist l->h, 2.sep h->l
    tb_dist_vec = []
    for i in range(length):
        for j in range(i, length):
            if(tb_dist_raw[i,j]) != 0:
                tb_dist_vec.append([i,j,tb_dist_raw[i,j]])
    tb_dist_vec = np.array(tb_dist_vec)
    # print(tb_dist_vec.shape)
    if len(tb_dist_vec) < 1:
        violate_count = 100000
        return violate_count, ab_dist
    tb_dist_sort = tb_dist_vec[np.argsort(tb_dist_vec, axis=0)][:,-1,:]

    for index in range(len(tb_dist_sort)):
        local_violate = 0
        i = int(tb_dist_sort[index][0])
        j = int(tb_dist_sort[index][1])
        tb_dist = tb_dist_sort[index][2]
        for k in range(length):
            D = [tb_dist, ab_dist_raw[j, k], ab_dist_raw[i, k]]
            if ab_dist_raw[j, k] == 0 or ab_dist_raw[i, k] == 0:
                continue
            index = np.argsort(D)
            if D[index[0]] + D[index[1]] < D[index[2]]:
                local_violate += 1
        if local_violate == 0:
            # print("%d %d: old %.4f new %.4f, change dist!"%(i, j, ab_dist[i,j], tb_dist))
            ab_dist[i,j] = tb_dist
        else:
            violate_count += 1
    return violate_count, ab_dist

def pHash(img):
    # img=cv2.imread(imgfile, 0)
    img=cv2.resize(img,(64,64),interpolation=cv2.INTER_CUBIC)
    h, w = img.shape[:2]
    vis0 = np.zeros((h,w), np.float32)
    vis0[:h,:w] = img
    vis1 = cv2.dct(cv2.dct(vis0))
    vis1.resize(32,32)
    # img_list=flatten(vis1.tolist())
    flatten = lambda x: [y for l in x for y in flatten(l)] if type(x) is list else [x]
    img_list =flatten(vis1.tolist())
    avg = sum(img_list)*1./len(img_list)
    avg_list = ['0' if i<avg else '1' for i in img_list]
    return ''.join(['%x' % int(''.join(avg_list[x:x+4]),2) for x in range(0,32*32,4)])

def hammingDist(s1, s2):
    assert len(s1) == len(s2)
    return sum([ch1 != ch2 for ch1, ch2 in zip(s1, s2)])

def trans2rank(inputlist):
    index =0
    outputlist = np.copy(inputlist)
    for i in np.argsort(inputlist):
        outputlist[i] = index
        if np.max(inputlist) != np.min(inputlist):
            index += 1
    return np.array(outputlist)

def trans2rank_allow_same(inputlist):
    index =0
    outputlist = np.copy(inputlist)
    sort_index = np.argsort(inputlist)
    for i in range(len(sort_index)):
        outputlist[sort_index[i]] = index
        if np.max(inputlist) == np.min(inputlist):
            continue
        if i != 0 and inputlist[sort_index[i]] == inputlist[sort_index[i-1]]:
            continue
        index += 1
    return np.array(outputlist)

if __name__=="__main__":
    parser = argparse.ArgumentParser()
    parser.description="DistTemplateRank - The best template ranking tool in the world."
    parser.add_argument("-m", "--model", help="input pdb path file or folder",type=str,required=True)
    parser.add_argument("-d", "--distmap", help="distance map, the name should be the fasta name",type=is_file,required=True)
    parser.add_argument("-f", "--fasta", help="fasta of target pdb", type=is_file, required=True)
    parser.add_argument("-o", "--outdir", help="output folder", type=str, required=True)

    args = parser.parse_args()
    file_or_dir = args.model
    distmap = args.distmap
    outdir = args.outdir
    fasta_file = args.fasta

    
    chkdirs(outdir + '/')
    seq_name = os.path.basename(distmap).split('.')[0]
    GLOABL_Path = os.path.dirname(sys.path[0])
    seq_length = 0

    file_list = open(fasta_file, 'r').readlines()
    if '>' in file_list[0]:
        fasta = file_list[1].strip('\n')
    else:
        fasta = file_list[0].strip('\n')
    seq_length = len(fasta)

    temp_pdb_file_list = []
    evalu_dict = {}
    prob_dict = {}
    if os.path.isdir(file_or_dir):
        all_file = os.listdir(file_or_dir)
        for file in all_file:
            if 'pdb' in file:
                pdb_name = file.split('.')[0]
                pdb_file = os.path.join(file_or_dir, file)
                temp_pdb_file_list.append(pdb_file)
            if 'evalu' in file:
                efile = open(os.path.join(file_or_dir, file))
                for line in efile.readlines():
                    line = line.strip('\n').split('\t')
                    evalu_dict[line[0]] = line[1]
                    prob_dict[line[0]] = line[-1]
    else:
        f = open(file_or_dir, 'r')
        for line in f.readlines():
            line = line.strip('\n')
            if 'pdb' not in line:
                line = line.split(' ')[0] + '.pdb'
            pdb_file = line
            temp_pdb_file_list.append(pdb_file)
    os.chdir(outdir)
    for pdb in temp_pdb_file_list:
        pdb_name = pdb.split('/')[-1].split('.')[0]
        if os.path.exists(outdir + '/' + pdb_name + '.map') == False:
            #transform pdb into dist map
            # print("perl %s/lib/pdb2dist.pl %s CB 0 > %s.dist"%(GLOABL_Path, pdb, pdb_name))
            os.system("perl %s/src/pdb2dist.pl %s CB 0 > %s.dist"%(GLOABL_Path, pdb, pdb_name))
            # print("perl %s/lib/generate-Y-realDistance.pl %s.dist %d > %s.map"%(GLOABL_Path, pdb_name, seq_length, pdb_name))
            os.system("perl %s/src/generate-Y-realDistance.pl %s.dist %d > %s.map"%(GLOABL_Path, pdb_name, seq_length, pdb_name))

    print("process %s..."%seq_name)
    # rank temp by dist
    tb_dist_dir = outdir
    info_txt = outdir +'/sum_info.txt'
    rank_txt = outdir +'/rank.txt'
    if os.path.exists(info_txt):os.remove(info_txt)
    if os.path.exists(rank_txt):os.remove(rank_txt)

    ab_dist = np.loadtxt(distmap)
    files = os.listdir(outdir)
    name_list = []
    violate_list = []
    evalu_list = []
    prob_list = []
    pearson_list = []
    rmse_list = []
    precl2_list = []
    precl2_long_list = []
    psnr_list = []
    ssim_list = []
    phash_list = []
    gist_list = []
    local_psnr_list = []
    local_ssim_list = []
    orb_num_list = []
    length = ab_dist.shape[0]
    mask_area = np.ones([length,length])
    mask_area = np.triu(mask_area, 12) + np.tril(mask_area, -12)
    mask_area = np.logical_and(mask_area, ab_dist <= 12)

    #read evalu
    with open(info_txt, 'a') as myfile:
        if evalu_dict:
            myfile.write("tb_dist_name\tevalu\tprob\trmse\tpearson\tprecl2\ttb_psnr\ttb_ssim\torn_num\n")
        else:
            myfile.write("tb_dist_name\trmse\tpearson\tprecl2\ttb_psnr\ttb_ssim\torn_num\n")

    for file in files:
        if 'map' in file:
            tb_dist_file = os.path.join(tb_dist_dir, file)
            tb_dist_name =os.path.basename(tb_dist_file).split('.')[0]
            ab_dist = np.loadtxt(distmap)
            tb_dist = np.loadtxt(tb_dist_file)
            print("analyse %s"%tb_dist_name)

            if evalu_dict:
                evalu = evalu_dict[tb_dist_name.split('_')[0]]
                evalu_list.append(evalu)
            if prob_dict:
                prob = prob_dict[tb_dist_name.split('_')[0]]
                prob_list.append(prob)
            #remove template with short arrange
            none_zero_num = np.count_nonzero(tb_dist)
            arrange_len = np.sqrt(none_zero_num)
            if arrange_len <= 20:
                print("template %s too short, skip!"%tb_dist_name)
            #violate
            violate_count, ab_dist_refine = combine_tbdist_into_abdist(tb_dist, ab_dist)
            #pearson
            tb_dist_bool = tb_dist == 0
            # pearson = stats.pearsonr((tb_dist*mask_area*tb_dist_bool).reshape(length * length), (ab_dist*mask_area*tb_dist_bool).reshape(length * length))  # scipy
            pearson = stats.pearsonr((tb_dist*mask_area).reshape(length * length), (ab_dist*mask_area).reshape(length * length))  # scipy
            #rmse
            rmse = np.mean(np.square((tb_dist*mask_area) - (ab_dist*mask_area)))
            # break
            #prec L/2
            # tb_bin_vec = tb_dist.flatten()
            # tb_bin_vec[tb_bin_vec<=8] = 1
            # tb_bin_vec[tb_bin_vec>8] = 0
            # ab_dist_copy = np.copy(ab_dist)
            # ab_dist_copy[ab_dist_copy < 1] = 1
            # ab_bin_vec = (1.0/ab_dist_copy).flatten()
            # ab_bin_vec = floor_lower_left_to_zero(ab_bin_vec, 24)
            # xL = int(0.5 * int(length)) #L/2
            # X_ceiled = np.zeros(len(ab_bin_vec))
            # X_ceiled[np.argpartition(ab_bin_vec, -xL)[-xL:]] = 1
            # X_ceiled[X_ceiled < 1]=0
            # ab_bin_vec = X_ceiled
            # precl2 = precision_score(tb_bin_vec, ab_bin_vec)
            tb_bin_vec = np.copy(tb_dist)
            tb_bin_vec[tb_bin_vec<=8] = 1
            tb_bin_vec[tb_bin_vec>8] = 0
            tb_bin_vec_6 = np.triu(tb_bin_vec, 6) + np.tril(tb_bin_vec, -6)
            tb_bin_vec_6 = tb_bin_vec_6.flatten()
            tb_bin_vec_24 = np.triu(tb_bin_vec, 24) + np.tril(tb_bin_vec, -24)
            tb_bin_vec_24 = tb_bin_vec_24.flatten()
            ab_bin_vec = np.copy(ab_dist)
            ab_bin_vec[ab_bin_vec<=8] = 1
            ab_bin_vec[ab_bin_vec>8] = 0
            ab_bin_vec_6 = np.triu(ab_bin_vec, 6) + np.tril(ab_bin_vec, -6)
            ab_bin_vec_6 = ab_bin_vec_6.flatten()
            ab_bin_vec_24 = np.triu(ab_bin_vec, 24) + np.tril(ab_bin_vec, -24)
            ab_bin_vec_24 = ab_bin_vec_24.flatten()
            precl2 = precision_score(tb_bin_vec_6, ab_bin_vec_6)
            precl2_long = precision_score(tb_bin_vec_24, ab_bin_vec_24)
            #psnr
            tb_bool = tb_dist > 0
            ab_dist[ab_dist > 15] = 15
            ab_dist *= 17.0
            # ab_dist = np.triu(ab_dist, 6) + np.tril(ab_dist, -6)
            tb_dist[tb_dist > 15]=15
            tb_dist *= 17.0
            # tb_dist = np.triu(tb_dist, 6) + np.tril(tb_dist, -6)

            # ab_dist *= tb_bool
            # tb_dist *= tb_bool
            tb_local_psnr = psnr(ab_dist*tb_bool, tb_dist)
            tb_psnr = psnr(ab_dist, tb_dist)
            #ssim
            tb_local_ssim = calc_ssim(ab_dist*tb_bool, tb_dist)
            tb_ssim = calc_ssim(ab_dist, tb_dist)
            #phash
            ab_dist_copy = np.copy(ab_dist)
            tb_dist_copy = np.copy(tb_dist)
            # ab_dist_copy = np.triu(ab_dist_copy, 6) + np.tril(ab_dist_copy, -6)
            # tb_dist_copy = np.triu(tb_dist_copy, 6) + np.tril(tb_dist_copy, -6)
            HASH1 = pHash(ab_dist_copy.astype(np.uint8))
            HASH2 = pHash(tb_dist_copy.astype(np.uint8))
            tb_phash = 1 - hammingDist(HASH1, HASH2) * 1. / (32 * 32 / 4)
            #gist
            gist_helper = GistUtils()
            np_gist = gist_helper.get_gist_vec(cv2.cvtColor(ab_dist_copy.astype(np.uint8), cv2.COLOR_GRAY2BGR), mode="gray")
            ab_gist_L2Norm = np_l2norm(np_gist)
            np_gist = gist_helper.get_gist_vec(cv2.cvtColor(tb_dist_copy.astype(np.uint8), cv2.COLOR_GRAY2BGR), mode="gray")
            tb_gist_L2Norm = np_l2norm(np_gist)
            tb_gist = np.inner(ab_gist_L2Norm, tb_gist_L2Norm)[0][0]
            #orb
            if tb_dist.sum() < 1:
                orb_num = 0
            else:
                img1 = cv2.cvtColor(ab_dist.astype(np.uint8), cv2.COLOR_GRAY2BGR)
                img2 = cv2.cvtColor(tb_dist.astype(np.uint8), cv2.COLOR_GRAY2BGR)
                orb = cv2.ORB_create()
                kp1, des1 = orb.detectAndCompute(img1, None)
                kp2, des2 = orb.detectAndCompute(img2, None)
                if des1 is None or des2 is None:
                    orb_num = 0
                else:
                    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=False)
                    matches = bf.knnMatch(des1, trainDescriptors = des2, k = 2)
                    good = []
                    for m, n in matches:
                        (x1, y1) = kp1[m.queryIdx].pt
                        (x2, y2) = kp2[m.trainIdx].pt
                        if m.distance < 0.7 * n.distance and abs(x1-x2) <= 2 and abs(y1-y2) <= 2:
                            good.append(m)
                    orb_num = len(good)

            # with open(info_txt, 'a') as myfile:
            #     if evalu_dict: 
            #         str_to_write = "%s\t%s\t%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%d\n"%(tb_dist_name, evalu, prob, rmse, pearson[0], precl2, tb_psnr, tb_local_psnr, tb_ssim, tb_local_ssim, orb_num)
            #     else:
            #         str_to_write = "%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%d\n"%(tb_dist_name, rmse, pearson[0], precl2, tb_psnr, tb_ssim, orb_num)
            #     myfile.write(str_to_write)

            name_list.append(tb_dist_name)
            violate_list.append(violate_count)
            pearson_list.append(pearson[0])
            rmse_list.append(rmse)
            precl2_list.append(precl2)
            precl2_long_list.append(precl2_long)
            psnr_list.append(tb_psnr)
            ssim_list.append(tb_ssim)
            phash_list.append(tb_phash)
            gist_list.append(tb_gist)
            local_psnr_list.append(tb_local_psnr)
            local_ssim_list.append(tb_local_ssim)
            orb_num_list.append(orb_num)

    if evalu_dict: 
        evalu_list = np.array(evalu_list).astype(np.float)
        evalu_norm = trans2rank_allow_same(evalu_list)
    if prob_dict: 
        prob_list = np.array(prob_list).astype(np.float)
        prob_norm = trans2rank_allow_same(prob_list)
        
    violate_list = np.array(violate_list)
    pearson_list = np.array(pearson_list)
    rmse_list = np.array(rmse_list)
    precl2_list = np.array(precl2_list)
    precl2_long_list = np.array(precl2_long_list)
    psnr_list = np.array(psnr_list)
    ssim_list = np.array(ssim_list)
    local_psnr_list = np.array(local_psnr_list)
    local_ssim_list = np.array(local_ssim_list)
    phash_list = np.array(phash_list)
    gist_list = np.array(gist_list)
    orb_num_list = np.array(orb_num_list)

    violate_norm = trans2rank_allow_same(violate_list)
    pearson_norm = trans2rank_allow_same(-pearson_list)
    rmse_norm = trans2rank_allow_same(rmse_list)
    precl2_norm = trans2rank_allow_same(-precl2_list)
    precl2_long_norm = trans2rank_allow_same(-precl2_long_list)
    psnr_norm = trans2rank_allow_same(-psnr_list)
    ssim_norm = trans2rank_allow_same(-ssim_list)
    local_psnr_norm = trans2rank_allow_same(-local_psnr_list)
    local_ssim_norm = trans2rank_allow_same(-local_ssim_list)
    phash_norm = trans2rank_allow_same(-phash_list)
    gist_norm = trans2rank_allow_same(-gist_list)
    orb_num_norm = trans2rank_allow_same(-orb_num_list)

    sum_info = []
    for i in range(len(name_list)):
        if evalu_dict: 
            temp_array = np.array([evalu_norm[i], prob_norm[i], rmse_norm[i], pearson_norm[i], precl2_norm[i], precl2_long_norm[i], 
                psnr_norm[i], local_psnr_norm[i], ssim_norm[i], local_ssim_norm[i], phash_norm[i], gist_norm[i], orb_num_norm[i]])
        else:
            temp_array = np.array([rmse_norm[i], pearson_norm[i], precl2_norm[i], precl2_long_norm[i], 
                psnr_norm[i], local_psnr_norm[i], ssim_norm[i], local_ssim_norm[i], phash_norm[i], gist_norm[i], orb_num_norm[i]])
        avg = np.average(temp_array)
        var = np.var(temp_array)
        if var > 1.5 * avg:
            thred = avg
        elif var > 3 * avg:
            thred = avg/2
        else:
            thred = avg + var
        temp_sum = []
        print(temp_array, avg + thred, avg - thred)
        for l in temp_array:
            if (l <= avg + thred) and (l >= avg - thred):
                temp_sum.append(l)
        print(temp_sum)
        temp_sum = np.array(temp_sum)
        sum_info.append(np.sum(temp_sum))
    if evalu_dict: 
        sum_info_origin = rmse_norm + pearson_norm + psnr_norm + ssim_norm + phash_norm + gist_norm + orb_num_norm
    else:
        sum_info_origin = rmse_norm + pearson_norm + precl2_norm + precl2_long_norm + psnr_norm + local_psnr_norm + ssim_norm + local_ssim_norm + phash_norm + gist_norm + orb_num_norm
    
    for i in range(len(name_list)):
        with open(info_txt, 'a') as myfile:
            if evalu_dict: 
                str_to_write = "%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n"\
                %(name_list[i], evalu_norm[i], prob_norm[i], rmse_norm[i], pearson_norm[i], precl2_norm[i], precl2_long_norm[i], psnr_norm[i], local_psnr_norm[i], ssim_norm[i], local_ssim_norm[i], phash_norm[i], gist_norm[i], orb_num_norm[i], sum_info_origin[i], sum_info[i])
                myfile.write(str_to_write)
            else:
                str_to_write = "%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n"\
                %(name_list[i], rmse_norm[i], pearson_norm[i], precl2_norm[i], precl2_long_norm[i], psnr_norm[i], local_psnr_norm[i], ssim_norm[i], local_ssim_norm[i], phash_norm[i], gist_norm[i], orb_num_norm[i], sum_info_origin[i], sum_info[i])
                myfile.write(str_to_write)


    # if evalu_dict:
    #     sum_info = evalu_norm +  (1-prob_norm) + 0.5 * rmse_norm + (1-pearson_norm) + 0.5 * (1-precl2_norm) \
    #      + (1-psnr_norm) +  (1-ssim_norm) + (1-local_psnr_norm) + (1-local_ssim_norm) + 0.7 * (1-orb_num_norm)
    # else:
    #     sum_info = 0.2 * rmse_norm + 0.6 * (1-pearson_norm) + 0.2*(1-precl2_norm) + 0.6*(1-psnr_norm) + 0.8*(1-ssim_norm) + 0.2*(1-orb_num_norm)# hhsuit local
    
    rank_index = np.argsort(sum_info_origin)
    temp_rank = []
    for i in range(len(rank_index)):
        temp_rank.append(name_list[rank_index[i]])
        with open(rank_txt, 'a') as myfile:
            str_to_write = "%s\t%.4f\n"%(name_list[rank_index[i]], sum_info_origin[rank_index[i]])
            myfile.write(str_to_write)