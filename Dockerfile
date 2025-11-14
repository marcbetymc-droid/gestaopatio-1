FROM python:3.11-slim

# Instala dependências de sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    python3-dev \
    libopenblas-dev \
    liblapack-dev \
    gfortran \
    libffi-dev \
    pkg-config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Instala dependências do projeto
RUN pip install --upgrade pip setuptools wheel

# Instala numpy com binários otimizados
RUN pip install numpy==1.26.4 --only-binary=:all:

# Instala dependências do requirements.txt
RUN pip install -r requirements.txt

# Instala pacotes adicionais necessários
RUN pip install redis python-dotenv

# Define variável de ambiente padrão para SQLite (pode ser sobrescrita por DATABASE_URL do ambiente)
ENV DATABASE_URL=sqlite:///data/agendamento.db

# Cria diretório para persistência de dados
RUN mkdir -p /app/data

# Expõe a porta da aplicação
EXPOSE 5000

# Comando para iniciar o app com Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--timeout", "600", "main:app"]
