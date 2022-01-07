FROM jupyter/scipy-notebook:hub-2.0.1

USER root

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

ENV NVARCH x86_64
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.2 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441 driver>=450"
ENV NV_CUDA_CUDART_VERSION 11.2.152-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-11-2

ENV NV_ML_REPO_ENABLED 1
ENV NV_ML_REPO_URL https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu2004/${NVARCH}

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH}/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    if [ ! -z ${NV_ML_REPO_ENABLED} ]; then echo "deb ${NV_ML_REPO_URL} /" > /etc/apt/sources.list.d/nvidia-ml.list; fi && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.2.2

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-2=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && ln -s cuda-11.2 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


ENV LC_ALL=ko_KR.UTF-8
ENV TZ=Asia/Seoul

RUN apt update && \
    apt install -y --no-install-recommends sudo build-essential git zsh curl vim less locales && \
    locale-gen ko_KR.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    chsh -s $(which zsh) && \
    conda init zsh && \
    conda install -y -c conda-forge nb_conda_kernels && \
    conda clean -y -a

RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/djui/alias-tips.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/alias-tips && \
    perl -pi -e 's/plugins\=\(git\)/plugins\=\(git zsh-syntax-highlighting alias-tips\)/g' ~/.zshrc

WORKDIR /jupyter-lab
