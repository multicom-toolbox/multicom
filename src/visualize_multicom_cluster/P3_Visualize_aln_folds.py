"""
=======================
Artist within an artist
=======================

Show how to override basic methods so an artist can contain another
artist.  In this case, the line contains a Text instance to label it.
"""
import numpy as np
import sys
import matplotlib
# Force matplotlib to not use any Xwindows backend.
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.lines as lines
import matplotlib.transforms as mtransforms
import matplotlib.text as mtext

import matplotlib.gridspec as gridspec

class MyLine(lines.Line2D):
    def __init__(self, *args, **kwargs):
        # we'll update the position when the line data is set
        self.text = mtext.Text(0, 0, '')
        lines.Line2D.__init__(self, *args, **kwargs)

        # we can't access the label attr until *after* the line is
        # inited
        self.text.set_text(self.get_label())

    def set_figure(self, figure):
        self.text.set_figure(figure)
        lines.Line2D.set_figure(self, figure)

    def set_axes(self, axes):
        self.text.set_axes(axes)
        lines.Line2D.set_axes(self, axes)

    def set_transform(self, transform):
        # 2 pixel offset
        texttrans = transform + mtransforms.Affine2D().translate(2, 2)
        self.text.set_transform(texttrans)
        lines.Line2D.set_transform(self, transform)

    def set_data(self, x, y):
        if len(x):
            #self.text.set_position((x[-1], y[-1]))
            self.text.set_position((2, y[-1]+0.2))

        lines.Line2D.set_data(self, x, y)

    def draw(self, renderer):
        # draw my label at the end of the line with 2 pixel offset
        lines.Line2D.draw(self, renderer)
        self.text.draw(renderer)
    
if __name__ == '__main__':

    #print len(sys.argv)
    if len(sys.argv) != 3:
            print 'please input the right parameters: list, model, weight, kmax'
            sys.exit(1)
    
    
    predictionfile=sys.argv[1] 
    outputfile=sys.argv[2]
    #fold_file=open('C:\Users\Jie Hou\Downloads\jie_test.txt','r').readlines() 
    fold_file=open(predictionfile,'r').readlines() 
    range_seq = fold_file[0].rstrip().split('\t')[0]
    start_seq = int(range_seq.split('-')[0])
    end_seq = int(range_seq.split('-')[1])
	
    if len(fold_file)> 10:
        ylimit = 2*11
    else:
        ylimit = 2*len(fold_file)
    #ylimit = 2*len(fold_file)
    
    #fig, ax = plt.subplots()


    gs = gridspec.GridSpec(1, 1)
    fig = plt.figure(figsize=(12,6))
    ax = fig.add_subplot(gs[0:1,0:1])
        
    ax.set_xlim([0,end_seq])
    ax.set_ylim([0,ylimit+2])
    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)
    for i in xrange(len(fold_file)):
        range_seq = fold_file[i].rstrip().split('\t')[0]
        fold = fold_file[i].rstrip().split('\t')[1]
        annotation = fold_file[i].rstrip().split('\t')[2]  

        start = int(range_seq.split('-')[0])
        end = int(range_seq.split('-')[1])
        
        if i > 10:
        	break

        if i ==0:
            x=np.array([start,end])
            y=np.array([ylimit-2*i,ylimit-2*i])
            line = MyLine(x, y, mfc='red', ms=12, label=fold)
            #line.text.set_text('line label')
            line.text.set_color('black')
            line.text.set_verticalalignment('bottom')
            line.text.set_fontsize(10)
            line.set_linewidth(10)
            ax.add_line(line)
        else:
            x=np.array([start,end])
            y=np.array([ylimit-2*i,ylimit-2*i])
            line = MyLine(x, y, mfc='red', ms=12, label=fold+'|'+annotation)
            #line.text.set_text('line label')
            line.text.set_color('black')
            line.text.set_verticalalignment('bottom')
            line.text.set_fontsize(10)
            line.set_linewidth(4)
            line.set_color('red')
            ax.add_line(line)
    
    #fig.savefig('C:\Users\Jie Hou\Downloads\jie_test.jpeg', dpi = 300) 
    fig.savefig(outputfile, dpi = 300) 

