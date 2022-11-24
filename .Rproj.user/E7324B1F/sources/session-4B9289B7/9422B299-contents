#' Computing the Cell State Deviations (CSDs) and the Cell Anomalousness Scores (CASs)
#'
#' @param feature.mat a matrix containing the feature vectors for each cells, each row represents one feature
#' @param anchor.frac the fraction of anchor cells, 0.15 by default
#' @param n.cores threads called for computation, 1 by default
#' @param verbose logical, whether report the computation progress
#' @param K the number of the nearest neighbors in computing the CASs
#'
#' @return list, containing CSDs and CASs
#' @export
#'
#' @examples
scores<-function(feature.mat, anchor.frac = 0.15, n.cores = 1,verbose = T, K=30){
  if(mode(feature.mat)=="list"){
    feature.mat<-as.matrix(feature.mat)
  }
  #the index of uniformly sampled cells
  uniform.sample.index<- sample(1:dim(feature.mat)[1],size = floor(anchor.frac*dim(feature.mat)[1]),replace = F)

  #distance matrix between anchors and other cells
  distance.cell2remain<-function(x,cell.num,red.dat){
    as.matrix(sapply(1:cell.num, function(y){
      if(x!=y){return(norm(as.matrix(red.dat[,x]-red.dat[,y]),"F"))}
      else{return(0)}
    }))
  }
  if(verbose == T){print("Constructing affinity matrix")}
  # computing affinity matrix
  H<-sapply(uniform.sample.index,function(x){
    distance.cell2remain(x = x, red.dat = t(feature.mat), cell.num = dim(feature.mat)[1])
  })

  # computing CSD
  if(verbose ==T){print("Computing the cell state deviations considering the distances from majority cells")}

  norm.H<-diag(1/apply(H,1,sum))%*%H
  W =norm.H%*%t(H)
  L<-diag(apply(W,1,sum)) - W
  scores<-sapply(1:dim(L)[1], function(x){L[x,x]})
  scores<-(-1)*scores
  scores<-(scores-min(scores))/(max(scores)-min(scores))

  # computing CAS
  if(verbose==T){print("Computing anomalous scores")}
  # W = H%*%t(H)
  W = norm.H%*%t(norm.H)
  cell.specific.knearest.locs<-t(parallel::mcmapply(function(x){
    return(order(W[x,],decreasing = T)[2:(K+1)])
  }, 1:dim(feature.mat)[1], mc.cores = n.cores))
  scores.knn<-parallel::mcmapply(function(x){
    mean(scores[cell.specific.knearest.locs[x,]])
  },1:length(scores),mc.cores = n.cores)
  anomalous.scores<-abs(scores-scores.knn)
  anomalous.scores<-(anomalous.scores-min(anomalous.scores))/(max(anomalous.scores)-min(anomalous.scores))

  return(list(CSD = scores, CAS = anomalous.scores))
}
