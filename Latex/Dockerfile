FROM ubuntu:24.04

# Отключаем интерактивные запросы при установке
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем полный пакет TeX Live
# Он уже включает в себя latexmk, поддержку кириллицы, все шрифты и пакеты
RUN apt-get update && apt-get install -y \
    texlive-full \
    make \
    && rm -rf /var/lib/apt/lists/*

# Рабочая директория внутри контейнера
WORKDIR /workspace

# Команда по умолчанию
CMD ["latexmk", "-pdf"]
