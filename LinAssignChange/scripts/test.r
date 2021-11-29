#from diffMat, get proportion of difference per lineage at any stage vs the next
#Binomial test
binomp=0.1
linBion<-do.call(rbind,lapply(alllin, function(lin0){
  diffMatYNlin<-diffMat==lin0
  colSums(diffMatYNlin, na.rm=T)
  ret=c()
  totCnt=alllincnt[lin0,]
  for (i in 1:(ncol(diffMat)-1)){
    if(totCnt[i]>0){
      ret[i]=binom.test(sum(diffMatYNlin[,i]==T&diffMatYNlin[,i+1]==F,na.rm=T),totCnt[i],p=binomp, alternative="greater")$p.value
    }else{
      ret[i]=NA
    }
  }
  p.adjust(ret,method="bonferroni")
}))
rownames(linBion)=alllin
colnames(linBion)=paste0(colnames(alllincnt)[-ncol(alllincnt)], "_to_", colnames(alllincnt)[-1])




comparei =2
  cntvsperc<-data.frame(count=linchangeCnt[,comparei], percent=linpercchange[,comparei], adjp=linBion[,comparei])
  cntvsperc<-na.omit(cntvsperc)
  #del<-cbind(cntvsperc, cntvsperc$adjp<0.05, order(cntvsperc$adjp))
   plotTopCnt=10
    
  #currently arbitrary
  #critLab<- cntvsperc$count>50 & cntvsperc$percent >10 
  #critLab<- cntvsperc$count>50 
  ### Binomial test with Bonferroni adjusted p
  critLab <- cntvsperc$adjp<0.05 & rownames(cntvsperc)%in%rownames(cntvsperctop)[1:plotTopCnt]
  
  
  p<-ggplot(cntvsperc)+aes(x=count, y=percent,label=ifelse(critLab,rownames(cntvsperc),""),fill=-1*log10(adjp) )+geom_point(pch = 21, size=2,alpha = 0.5)+ scale_x_continuous(trans='log10')+
    scale_fill_gradient2(low = "white", mid="yellow",high = "red", midpoint=2.995732, na.value = "red") 
  
  suppressWarnings(print(p + geom_text_repel()+ labs(title = colnames(linchangeCnt)[comparei])))

  print(colnames(linchangeCnt)[comparei])
  if(sum(cntvsperc$adjp<0.05)>plotTopCnt){
    print(head(cntvsperc[order(cntvsperc$adjp),],plotTopCnt))
  }else{
    tmp<-cntvsperc[order(cntvsperc$adjp),]
    print(tmp[tmp$adjp<0.05,])
  }
  
  ### printing lineages with <0.05 adjusted p
  ### to be updated, do significant changes
  #for (i in 1:ncol(linpercchange))
  cbind(linpercchange,linchangeCnt,linBion)[rowSums(linBion<0.05,na.rm=T)>0,]
  
  
  
  
  
#linchange: count, perc, Binomial test
binomp=0.1
linchangeByLin<-lapply(alllin, function(lin0){
  diffMatYNlin<-diffMat==lin0
  colSums(diffMatYNlin, na.rm=T)
  ret=matrix(NA, nrow = (ncol(diffMat)-1), ncol = 3)
  totCnt=alllincnt[lin0,]
  for (i in 1:(ncol(diffMat)-1)){
    if(totCnt[i]>0){
      thiscnt=sum(diffMatYNlin[,i]==T&diffMatYNlin[,i+1]==F,na.rm=T)
      ret[i,]=c(thiscnt, thiscnt/totCnt[i]*100,
        binom.test(thiscnt,totCnt[i],p=binomp, alternative="greater")$p.value)
    }
    
  }
  ret
})


#rownames(linchange)=alllin
#colnames(linchange)=paste0(colnames(alllincnt)[-ncol(alllincnt)], "_to_", colnames(alllincnt)[-1])


##################### pie ggplot2


## Generate a pie chart of the change pairs to get a sense of the proportion
#top topl=5 change pairs  
simplifiedPie<-function(x,topl=5,nameAdd=""){
  if(length(x)>0){
    crit <- order(x, decreasing=T)<=topl
    x2<-x[crit]
    if(sum(!crit)>0){
      x2<-c(x2,sum(x[!crit]))
      names(x2)[length(x2)]="Others"
    }
    #pie(x2,main=paste0(nameAdd,": ",length(x)," changes in total"))
    piedat<-data.frame(cate=names(x2),Freq=x2)
    # Basic piechart
    ggplot(piedat, aes(x="", y=Freq, fill=cate)) +
      geom_bar(stat="identity", width=1, color="white") +
      coord_polar("y", start=0) +
      geom_text(aes(label = Freq), position = position_stack(vjust=0.5)) +
      labs(x = NULL, y = NULL, fill = "Lineage Change")+
      theme_void() 
  }else{print(paste("No changes in", nameAdd))}
}
simplifiedPie(changePairs[[y]],nameAdd=names(changePairs)[y])


if(nrow(diffMat)!=0){ ## if there are changes
  
  changePairs<-lapply(1:(ncol(diffMat)-1),function(i){
    tc<-diffMat[,i]!=diffMat[,i+1]& !is.na(diffMat[,i]) & !is.na(diffMat[,i+1]) 
    sort(table(paste(diffMat[tc,i],diffMat[tc,i+1],sep="_")), decreasing=T)
  })
  names(changePairs)=colnames(linpercchange)
  
  ## print top 10 change pairs or those with changes of > 50 samples 
  lapply(changePairs,function(y) head(y,max(10,sum(y>50))))
  
  
  #Pie chart generation
  for(y in 1:length(changePairs)){
    simplifiedPie(changePairs[[y]],nameAdd=names(changePairs)[y])
    

  }
  
}else{
  
  print("No change.")
  
}





###################
#diffMat<-compLinDiffMulti(compChoice, options="changesAndAppeared")

compLinDiffMulti<-function(listInput, options="changesOnly"){
  listInput<-lapply(listInput, function(y)y[!duplicated(y$taxon),]) ## remove duplicated samples in the same time point, happens in desig
  tmp<-table(unlist(lapply(listInput, function(y)y$taxon)))
  if(options=="changesOnly"){
    commonSamp<-names(tmp)[tmp>1]##samples present in at least two stages, can't have this
  }else{
    commonSamp<-names(tmp)
  }
  
  tmp2<-do.call(cbind,lapply(listInput, function(y,commonSamp){
    nseen<-setdiff(commonSamp,y$taxon)
    if(length(nseen)>0){
      y=rbind(y,cbind(taxon=nseen,lineage=rep(NA,length(nseen))))
    }
    rownames(y)=y$taxon;
    y[commonSamp,"lineage"]
  }, commonSamp=commonSamp))
  
  if(options=="changesOnly"){
    
    whichDiff<- apply(tmp2,1,function(y){y=na.omit(y);sum(y!=y[length(y)],na.rm=T)>0}) 
  }
  if(options=="changesAndAppeared"){
    whichDiff<- apply(tmp2,1,function(y){sum(y==y[length(y)],na.rm=T)!=length(y)})
  }
  if(options=="all"){
    whichDiff<- 1:nrow(tmp2)
  }
  #print(paste(names(listInput),"had",sapply(listInput,nrow),"samples", collapse=", "))
  #print(paste("Common sample count is",nrow(tmp2), ", number of different assignments is",sum(whichDiff)))
  diffMat<-tmp2[whichDiff,]
  rownames(diffMat)=commonSamp[whichDiff]
  diffMat
  
}
