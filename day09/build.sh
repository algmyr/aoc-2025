#!/bin/bash
carbon compile --optimize=speed *.carbon \
    && carbon link --output="main" *.o
