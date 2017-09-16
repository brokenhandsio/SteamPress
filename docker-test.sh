#!/bin/bash
docker build --tag steampress .
docker run --rm steampress
