require 'net/http'

class HomeController < ApplicationController
  def index
  end

  def analyze
    description = params[:description]
    curriculum = params[:curriculum]

    prompt = <<~PROMPT
      Analise a descrição da vaga e o currículo.

      DESCRIÇÃO DA VAGA:
      #{description}

      CURRÍCULO:
      #{curriculum}

      Retorne o curriculo atualizado com a melhor adequação com a vaga, ja 
      trabalhei com todas as tecnologias exigidas na vaga nas minhas na caixa e na Ayabese, quero apenas o Markdown como 
      resposta e ajuste tambem o tipo do meu cargo "Software Engineer" para um que se encaixe melhor com oque a vaga pede,
      por exemplo uma vaga de react seria "React Developer | TypeScript | APIs REST | IA Generativa | Automações | PostgreSQL", 
      não faça nenhum comentarios no curriculo como "Datas ajustadas para refletir um período de trabalho passado e válido" e nem ajuste as datas
    PROMPT

    api_key = ENV["GEMINI_API_KEY"]

    uri = URI(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=#{api_key}"
    )

    response = Net::HTTP.post(
      uri,
      {
        contents: [
          {
            parts: [
              {text: prompt}
            ]
          }
        ]
      }.to_json,
      "Content-Type" => "application/json"
    )

    json = JSON.parse(response.body)

    @result = json["candidates"][0]["content"]["parts"][0]["text"]

    render "home/index"
  end
end
