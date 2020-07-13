#!/bin/bash
for i in *.json;
do
	echo $i
	python -m json.tool $i > $i.unflat 
done
