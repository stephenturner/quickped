
# Main pedigree plot function
plotPed = function(pedData, plotargs, selected = NULL, addBox = FALSE) {
  dat = tryCatch(
    plot(pedData$ped,
         aff        = pedData$aff,
         carrier    = pedData$carrier,
         deceased   = pedData$deceased,
         twins      = pedData$twins,
         col        = list(red = selected),
         labs       = switch(plotargs$showlabs, show = breakLabs, hide = NULL),
         cex        = plotargs$cex,
         symbolsize = plotargs$symbolsize,
         margins    = plotargs$mar),
    error = function(e) {
      msg = conditionMessage(e)
      if(grepl("reduce cex", msg))
        msg = "Plot region is too small"
      stop(msg)
    }
  )

  if(addBox)
    box("outer", col = 1)

  # Return plot object for storage
  dat
}


# Current plot labels in the order plotted
getPlotOrder = function(ped, plist, perGeneration = FALSE) {

  # Index of each indiv, listed by generation
  idxList = lapply(seq_along(plist$n), function(i) plist$nid[i, 1:plist$n[i]])

  # Check for dups
  dups = duplicated(unlist(idxList))

  if(any(dups)) {
    # Generation number of each (used to remove dups)
    g = rep(seq_along(plist$n), plist$n)

    # Reduce
    g2 = g[!dups]

    # Create new idxList
    idxList = split(unlist(idxList)[!dups], unlist(g2))
  }

  if(perGeneration)
    lapply(idxList, function(v) labels(ped)[v])
  else
    labels(ped)[unlist(idxList)]
}


# Prepare data for updating labels in plot
updateLabelsData = function(currData, old, new, reorder = FALSE) {

  newtw = currData$twins
  newtw$id1 = new[match(newtw$id1, old)]
  newtw$id2 = new[match(newtw$id2, old)]

  list(ped = relabel(currData$ped, old = old, new = new, reorder = reorder),
       aff = new[match(currData$aff, old)],
       carrier = new[match(currData$carrier, old)],
       deceased = new[match(currData$deceased, old)],
       twins = newtw)
}

breakLabs = function(x, breakAt = "  ") {
  labs = labels(x)
  names(labs) = sub(breakAt, "\n", labs)
  labs
}


plotKappa = function(k, ids, col = "blue") {
  showInTriangle(k, cex = 2.5, lwd = 3.5, col = "blue", cexPoint = 1.6,
                 cexText = 1.6, labels = FALSE)
  lab = paste(ids, collapse = " - ")
  adj = c(.5, -1.25)
  n = nchar(lab)
  if(k[1] == 0 && n >= 20) adj[1] = 0.25
  else if(n > 46 - 30*k[1]) adj[1] = 0.5 + (1 - (46 - 30*k[1])/n)

  text(k[1], k[3], lab, cex = 1.5, col = col, adj = adj)
  text(.45, .45, 'inadmissible region', cex = 1.2, srt = -45)
}
