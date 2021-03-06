#!/bin/sh

# Package up lambda function and layer for tf deployment via Github Actions
zip src/lambda_function_payload.zip src/main.py
zip -r package/lambda_layer_payload.zip package/python/
