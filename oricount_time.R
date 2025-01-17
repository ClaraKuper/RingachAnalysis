## to do
# quadradic axis
# radian to degree
# time from left to right
# farbachse min=black max=rgb(255,215,0,max=255)



# timing on long data format

new_data<-read.table(paste(path_script,'long.format.txt',sep="")) # the long data format as generated by reshape.data

# reset time to stimulus offset
new_data$time2 <- new_data$telSequenceOn1+round(4*1000/120)-new_data$sacOnset
timesteps <- seq(0,-198,-1) # set the length for each timebin
participants <- unique(new_data$vp)
conditions <- unique(new_data$testcond)
orientations <- unique(new_data$ori1)
collect.table<-matrix(nrow=length(conditions)*length(participants)*(1+length(unique(new_data$ori1))),ncol=3+length(timesteps)) #new table to collect data
orirow<-0 #initiate the counter for rows
pos_data <- new_data[which(new_data$respTilt==1),] #subset of yes-answers

for (vp in participants){
  part_data<-pos_data[which(pos_data$vp==vp),]
  for (cond in conditions){
    for (ori in (sort(c(orientations,-0.5)))){ #this is for the orientation of interest
      if(ori==-0.5){ #the value -.5 is equal to .5
        ori<-0.5
        checkval <- TRUE
      }
      else {
        checkval<-FALSE
      }
      orirow<-orirow+1 #rowcounter
      if (checkval){
        collect.table[orirow,1]<- -ori*180
      }
      else {
        collect.table[orirow,1]<-ori*180 #write current orientation to table
      }
      collect.table[orirow,2]<-cond #write condition to table
      collect.table[orirow,3]<-vp
      timecol<-3 #reset column counter  
      for (tdv in timesteps){ 
        timewin <- seq(tdv,(tdv-32),-1)
        timecol<-timecol+1 # column counter
        oricount<-0 # set a counter how often the orientation offset was in this timewindow
        for(rows in 1:nrow(part_data)){ 
          if(part_data[rows,27]==ori&part_data[rows,9]==cond){  # orientation
            if(is.element(part_data[rows,46],timewin)){
              # intially, the time information is set to presentation offset, 
              #i.e. if the time point of interest (tdv) falls within a period of stim. offset to 30ms before, the correspondig orientation was 
              #presented at tdv
              oricount<-oricount+1 #counter 
            }   
          }
        }
        if (oricount==0){
          yes.ori<-0
        }
        else if (oricount!=0){
          allcount <- nrow(new_data[which(is.element(new_data[,46],timewin)&new_data[,27]==ori&new_data[,9]==cond&new_data[,1]==vp),])
          yes.ori <- oricount/allcount
          if (is.nan(yes.ori)){
            print(paste('NaN in vp', vp, 'timepoint', tdv, 'orientation', ori, 'conditon', cond, "allcount", allcount, "oricount", oricount, sep=" "))
          }  
        }
        collect.table[orirow,timecol]<-round(yes.ori,digits=3) #write the counter information to the table
      }
    }
  }  
}

colnames(collect.table)<-c("orientation","condition","vp",timesteps)
write.table(collect.table,"ori.table.txt",sep="\t")
###########PLOTTING#################
collect.table<-read.table(paste(path_script,'ori.table.txt',sep=""))
collect.table <- as.data.frame(collect.table)
colnames(collect.table)<-c("orientation","condition","vp",timesteps)

# melt and reshape date accoring to paricipant mean values
collect.m<-melt(collect.table,id=c("orientation","condition","vp"),measure=paste(timesteps))
collect.c<-cast(collect.m,orientation+condition~variable,mean)
collect.p <- melt(collect.c,id=c("orientation","condition"),measure=paste(timesteps))

# tell r about categories of the stimuli
collect.p$condition<-as.factor(collect.p$condition) 
collect.p$orientation<-as.factor(collect.p$orientation) # factorial orientations give a better plotting
collect.p$variable<-as.numeric(collect.p$variable)
levels(collect.p$condition)<-c("congruent","incongruent") # naming is important for the plots
collect.p$variable<- -collect.p$variable 
colnames(collect.p)<-c("orientation","condition","conditional_probability","variable")

con <- ggplot(collect.p, aes(variable, orientation)) +facet_grid(condition~.)+ 
  geom_tile(aes(fill = conditional_probability,colour=conditional_probability),size=1)+
  scale_fill_gradient(limits=c(min(collect.p$conditional_probability), max(collect.p$conditional_probability)), low = "black",high = mygold) +
  scale_color_gradient(limits=c(min(collect.p$conditional_probability), max(collect.p$conditional_probability)), low = "black",high = mygold)+
  theme(aspect.ratio=1)+xlab("time in ms")+ylab("orientation in degree")+	theme(panel.grid.major=element_blank()) +
  theme(panel.grid.minor=element_blank()) +
  theme(panel.background=element_blank()) +
  theme(panel.border=element_blank()) +
  theme(plot.background=element_blank())
pdf(paste(path_figures,"heatmap per condition.pdf",sep=""), width = 8.27, height = 11.96)
print(con)
dev.off()

#as line diagrams
#plot01 <- ggplot(collect.table, aes(V1, V3, colour = as.factor(V2)))
#plot01 <- plot01+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('0 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))

#plot02 <- ggplot(collect.table, aes(V1, V4, colour = as.factor(V2)))
#plot02 <- plot02+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('  -33 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))

#plot03 <- ggplot(collect.table, aes(V1, V5, colour = as.factor(V2)))
#plot03 <- plot03+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('  -66 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))

#plot04 <- ggplot(collect.table, aes(V1, V6, colour = as.factor(V2)))
#plot04 <- plot04+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('  -99 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))

#plot05 <- ggplot(collect.table, aes(V1, V7, colour = as.factor(V2)))
#plot05 <- plot05+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('  -129 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))

#plot06 <- ggplot(collect.table, aes(V1, V8, colour = as.factor(V2)))
#plot06 <- plot06+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('  -165 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))

#plot07 <- ggplot(collect.table, aes(V1, V9, colour = as.factor(V2)))
#plot07 <- plot07+geom_line()+scale_y_continuous(limits = c(0,0.25))+
#  mytheme+ggtitle('  -198 ms')+xlab('orientation')+ylab('P(yes|orientation)')+scale_color_manual(values=c('#669933','#666666'))


#viewport 
#dev.off()
#pushViewport(viewport(layout = grid.layout(3,4)))

#print(plot01, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
#print(plot02, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
#print(plot03, vp = viewport(layout.pos.row = 1, layout.pos.col = 3))
#print(plot04, vp = viewport(layout.pos.row = 1, layout.pos.col = 4))
#print(plot05, vp = viewport(layout.pos.row = 2, layout.pos.col = 1))
#print(plot06, vp = viewport(layout.pos.row = 2, layout.pos.col = 2))
#print(plot07, vp = viewport(layout.pos.row = 2, layout.pos.col = 3))
