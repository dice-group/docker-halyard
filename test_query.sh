#!/bin/bash
echo "getting repos"

wget -O - http://halyard.eval.aksw.org/rdf4j-workbench/repositories | xmllint --format -

echo "getting info on benchmark10 repo"

wget -O - "http://halyard.eval.aksw.org/rdf4j-server/repositories/benchmark10?query=select%20%2A%20%7B%3Fs%20%3Fp%20%3Fo%7D%20limit%2010" 

echo "getting info on benchmark50 repo"
wget -O - "http://halyard.eval.aksw.org/rdf4j-server/repositories/benchmark50?query=select%20%2A%20%7B%3Fs%20%3Fp%20%3Fo%7D%20limit%2010" 
