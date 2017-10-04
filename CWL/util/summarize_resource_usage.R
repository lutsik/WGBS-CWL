
NODES=c("vm-0-167","vm-0-175","vm-1-12","vm-1-13","vm-1-14","vm-1-15")
RESOURCES=c("load_avg","mem_used")
PLOT_LABS=c("CPU usage", "RAM usage, GB")
names(PLOT_LABS)<-RESOURCES
		
res_list<-list()
for(res in RESOURCES){
	res_list[[res]]<-list()
	for(node in NODES){
		values=read.table(sprintf("node_%s_%s.dat", node, res))
		n<-length(values$V1)
		if(res=="mem_used"){
			usage_vals<-values$V1/1000
		}else{
			usage_vals<-values$V1
		}
		res_list[[res]][[node]]<-data.frame(time=(1:n)*5/60, resource=rep(res,n), node=rep(node,n), usage=usage_vals)
	}
}


database<-do.call("rbind",unlist(res_list, recursive=FALSE))

library(ggplot2)
library(grid)
library(gridExtra)
library(gtable)



period_start<-40
period_end<-72
pdf(sprintf("summary_plot_%d_to_%d_hours_common.pdf", period_start, period_end), width=10, height=5)
gpl<-list()
for(res in RESOURCES){
	gpl[[res]]<-ggplot(database[database$resource==res & database$time>=period_start & database$time<period_end,], 
			aes(x=time-period_start, y=usage, color=node))+geom_line()+xlab("Time, hours")+ylab(PLOT_LABS[res])+
			theme(axis.title.x = element_blank())
}
legend <- gtable_filter(ggplotGrob(gpl[[1]]), "guide-box") 

grid.arrange(do.call("arrangeGrob", c(lapply(gpl, "+", theme(legend.position="none")), list(ncol=1, bottom=textGrob("Time, hours")))),
		legend, 
		widths=unit.c(unit(3, "lines"), unit(1, "npc") - unit(3, "lines") - legend$width, legend$width), nrow=1)
dev.off()


