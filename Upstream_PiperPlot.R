library(smwrGraphs)
library(smwrData)

# data(MiscGW)

setPDF <- function(layout="portrait", basename="USGS", multiplefiles=FALSE) {
  ## set global variables for lineweights and pdf
  options(.lwt_factor = 1)
  options(.pdf_graph = TRUE)
  fontSize <- 8
  if(class(layout) == "list") { # custom
    width <- layout$wid
    height <- layout$hei
    fin <- c(width, height) - .1
  }
  else {
    layout=match.arg(layout, c("portrait", "landscape")) 
    if(layout == "portrait") {
      fin <- c(7.25, 9.5)
      width=8.5
      height=11.
    }
    else { # landscape
      fin <- c(9.5, 7.25)
      width=11.
      height=8.5
    }
  }
  
  name <- make.names(basename) # make a legal name
  ## set up the output
  if(multiplefiles) # make name
    name <- paste(name, "%03d.pdf", sep="")
  else
    name <- paste(name, ".pdf", sep="")
  PDFFont <- "Helvetica-Narrow"
  pdf(file=name, onefile=!multiplefiles, width=width, height=height,
      family=PDFFont, pointsize= fontSize, colormodel="cmyk", title=basename) 
  
  ## set up for export to PDF file.
  if(all(names(pdfFonts()) != "USGS")) # Check to see if already in the PDF font list
    pdfFonts("USGS" = Type1Font("Helvetica-Narrow",
                                pdfFonts("Helvetica-Nar row")[[1L]]$metrics))
  dev <- dev.cur()
  par(fin=fin, las=1)
  invisible(list(dev=dev, name=basename))
} 

up_costarica <- read.csv("upstream_forpiper.csv")

# Transform the data. 
PD <- transform(up_costarica, Ca.meq = conc2meq(Calcium, "calcium"),
                Mg.meq = conc2meq(Magnesium, "magnesium"),
                Na.meq = conc2meq(Sodium, "sodium"),
                Cl.meq = conc2meq(Chloride, "chloride"),
                SO4.meq = conc2meq(Sulfate, "sulfate"),
                NO3.meq = conc2meq(Nitrate, "nitrate as n"))
# abbreviations allowed in the call to conc2meq
# The row name identifies the sample source, create a column
PD$SS <- row.names(PD)
# The minimum page size for a Piper plot is 7 inches. No check is made,
# but the axis title spacings require a graph area of at least 6 inches.
setPDF("upstream_piper1", layout="portrait")
# setPNG("upstream_piper1", width=10, height=10)
# For this example, a separate graph area for an explanation is not needed
# because there are only 4 groups (individuals).
AA.pl <- with(PD, piperPlot(Ca.meq, Mg.meq, Na.meq,
                            Cl.meq, NO3.meq, SO4.meq,
                            Plot=list(name=X, color=setColor(X)),
                            zCat.title = "Sodium",
                            xAn.title = "Chloride",
                            yAn.title = "Nitrate"))
addExplanation(AA.pl, where="ul", title="Upstream")
# Required call to close PDF output graphics
graphics.off()