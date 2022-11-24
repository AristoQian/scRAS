#' Visualization of CSDs and CASs
#'
#' @param feature.mat a matrix containing the feature vectors for each cells, each row represents one feature
#' @param scores a list returned by scores() function, containing the CSDs and CASs computed
#' @param cell.labels vector, the annotations, cell types or clusters of individual cells
#' @param size the size of points, o.25 by default
#'
#' @return a list of three t-SNE visualization plots containing the gradient plot of CSDs and CASs and the visualization of cells with labels
#' @export
#'
#' @examples
visualize<-function(feature.mat, scores, cell.labels, size = 0.25){
  library(ggplot2)
  tsne<-Rtsne::Rtsne(feature.mat,pca = F)
  df<-data.frame(tsne1 = tsne$Y[,1], tsne2 = tsne$Y[,2],
                 CAS = scores$CAS, CSD = scores$CSD,
                 labels = cell.labels)
  plt1 <- ggplot(df, aes(x = tsne1, y = tsne2))+geom_point(aes(color = cell_ontology_class),size = size)
  plt2 <- ggplot(df, aes(x = tsne1, y = tsne2))+geom_point(aes(color = CSD), size = size)
  plt3 <- ggplot(df, aes(x = tsne1, y = tsne2))+geom_point(aes(color = CAS), size = size)

  theme.adj<-function(plt, legend.title, x.axis.title = "t-SNE 1",y.axis.title = "t-SNE 2"){
    plt$labels$x<-x.axis.title
    plt$labels$y<-y.axis.title
    plt<-plt+guides(guide_legend(legend.title))+scale_colour_gradient(low = "green", high = "red", guide = "colourbar", name = legend.title)
    plt$theme$panel.background<-element_blank()
    plt$theme$axis.line.x<-element_line(colour = "black", linewidth  = rel(1.5))
    plt$theme$axis.line.y<-element_line(colour = "black", linewidth = rel(1.5))
    return(plt)
  }

  plt2<-theme.adj(plt = plt2, legend.title = "CSD")
  plt3<-theme.adj(plt = plt3, legend.title = "CAS")

  return(list(plt.label = plt1, plt.CSD = plt2, plt.CAS = plt3))
}
