FROM --platform=${BUILDPLATFORM} python:3.8-slim
EXPOSE 8501

RUN apt-get update \
    && apt-get install -y build-essential

WORKDIR /app

COPY requirements.txt ./requirements.txt
RUN pip install -r requirements.txt


COPY . .
ENTRYPOINT ["streamlit", "run", "main.py", "--server.port=8501", "--server.address=0.0.0.0"]
