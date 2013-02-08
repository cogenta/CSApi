#!/bin/sh
#headerdoc2html \
#    --tocformat iframes \
#    --output-directory Docs \
#    CSApi/
#gatherheaderdoc Docs index.html
appledoc \
    --project-name CSAPI \
    --project-company "Cogenta Systems Ltd" \
    --company-id com.cogenta \
    --output Docs/ \
    CSApi/CSApi.h
appledoc \
	--project-name CSAPI \
	--project-company "Cogenta Systems Ltd" \
	--company-id com.cogenta \
	--output Docs/ \
	--no-create-docset \
	CSApi/CSApi.h
