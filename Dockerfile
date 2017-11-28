FROM ubuntu:16.04

# general
RUN apt-get update && apt-get install -y build-essential cmake \ 
    wget git unzip \
    yasm pkg-config software-properties-common python3-software-properties

# get python 3.6.3 
RUN add-apt-repository ppa:jonathonf/python-3.6 && apt-get update && \
    apt-get install -y python3.6 python3.6-dev python3.6-venv

# for tesseract ; why doesn't it work at below after python ln change??
RUN add-apt-repository ppa:alex-p/tesseract-ocr && apt-get update

# lib for opencv
RUN apt-get update && apt-get install -y  libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libdc1394-22-dev \
    libxvidcore-dev libx264-dev libgtk-3-dev libmagic-dev \
    libatlas-base-dev gfortran liblapack-dev \
    libtbb2 libtbb-dev libpq-dev

# pip stuff
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.6 get-pip.py && \
    python3.6 -m pip install pip --upgrade

RUN rm -f /usr/bin/python && ln -s /usr/bin/python3.6 /usr/bin/python
RUN rm -f /usr/bin/python3 && ln -s /usr/bin/python3.6 /usr/bin/python3
RUN rm -f /usr/local/bin/pip && ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip
RUN rm -f /usr/local/bin/pip3 && ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip3

# numpy etc
RUN pip install wheel && \
    pip install numpy && \
    pip install pandas && \
    pip install scipy && \
    pip install scikit-learn && \
    pip install python-magic

# lib for tesseract
RUN apt-get update && apt-get install -y g++ autoconf automake libtool \
    autoconf-archive zlib1g-dev libicu-dev libpango1.0-dev libcairo2-dev

# tesseract 4
RUN apt-get update && apt-get install -y libleptonica-dev \
    libtesseract4 \
    libtesseract-dev \
    tesseract-ocr

# Get language data.
RUN apt-get install -y \
    tesseract-ocr-osd \
    tesseract-ocr-equ \
    tesseract-ocr-ara \
    tesseract-ocr-deu \
    tesseract-ocr-fra \
    tesseract-ocr-heb \
    tesseract-ocr-hin \
    tesseract-ocr-ita \
    tesseract-ocr-jpn \
    tesseract-ocr-kor \
    tesseract-ocr-pol \
    tesseract-ocr-por \
    tesseract-ocr-rus \
    tesseract-ocr-spa \
    tesseract-ocr-tha \
    tesseract-ocr-tur \
    tesseract-ocr-vie \
    tesseract-ocr-chi-sim \
    tesseract-ocr-chi-tra \
    tesseract-ocr-eng
    # add more if needed

RUN apt-get -y clean all && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /

# opencv
RUN wget https://github.com/Itseez/opencv/archive/3.3.1.zip -O opencv.zip \
    && unzip opencv.zip \
    && wget https://github.com/Itseez/opencv_contrib/archive/3.3.1.zip -O opencv_contrib.zip \
    && unzip opencv_contrib \
    && mkdir /opencv-3.3.1/build \
    && cd /opencv-3.3.1/build \
    && cmake -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-3.3.1/modules \
        -DBUILD_TIFF=ON \
        -DBUILD_opencv_java=OFF \
        -DWITH_CUDA=OFF \
        -DENABLE_AVX=ON \
        -DWITH_OPENGL=ON \
        -DWITH_OPENCL=ON \
        -DWITH_IPP=ON \
        -DWITH_TBB=ON \
        -DWITH_EIGEN=ON \
        -DWITH_V4L=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DCMAKE_CXX_FLAGS=-std=c++11 \
        -DENABLE_PRECOMPILED_HEADERS=OFF \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DBUILD_opencv_python3=ON \
        -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
        -DPYTHON_EXECUTABLE=$(which python3.6) \
        -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
    && make install \
    && rm /opencv.zip \
    && rm /opencv_contrib.zip \
    && rm -r /opencv-3.3.1 \
    && rm -r /opencv_contrib-3.3.1


RUN mkdir /home/workspace
WORKDIR /home/workspace
