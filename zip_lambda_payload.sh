#!/bin/sh

# Package up lambda function and layer for tf deployment via Github Actions
cd src
zip lambda_function_payload.zip main.py
cd ../package
zip -r lambda_layer_payload.zip python/
