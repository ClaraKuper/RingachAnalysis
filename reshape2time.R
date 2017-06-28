# Reshape data, lock timing to stimulus Offset
new_data <- data
maxcol<-ncol(new_data)
timeseq <-which(colnames(new_data)=='telFixDot' )
for (e in 1:12){
  new_data[,maxcol+e]<-new_data[,timeseq+e]+round(4*1000/120)-new_data$sacOnset
} 
# For time bins in steps of 10 ms each
timestep <- 9
time.columns <- c((maxcol+1):ncol(new_data))
ori.columns <- c(37:48)
counter <- 1
for (n in seq(-400,100,10)){
  t.win <-n:(n+timestep)
  for (colnum in time.columns){
    collect <- c()
    for (rows in 1:nrow(new_data)){
      if (is.element(new_data[colnum,rows],t.win)){
        collect<-cbind(collect,new_data[rows,ori.columns[counter]])
      }
    print(table(collect))
    counter <- counter+1
      }
  }
}
