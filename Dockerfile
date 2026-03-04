FROM texlive/texlive:latest

WORKDIR /app

# Instalar pandoc y make
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    make \
    && rm -rf /var/lib/apt/lists/*


CMD ["make"]