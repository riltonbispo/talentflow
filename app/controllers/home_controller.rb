require 'net/http'

class HomeController < ApplicationController
  def index
  end

  def analyze
    description = params[:description]
    curriculum = params[:curriculum]

    prompt = <<~PROMPT
      Você é um especialista em recrutamento técnico, ATS (Applicant Tracking System) e elaboração de currículos para desenvolvedores de software.

      Sua tarefa é adaptar o currículo fornecido para maximizar sua compatibilidade com a vaga, mantendo um tom profissional, natural e totalmente coerente com a experiência já existente.

      ## Descrição da vaga

      #{description}

      ## Currículo atual

      #{curriculum}

      ## Instruções

      - Reescreva o currículo em Markdown.
      - Retorne APENAS o currículo. Não faça comentários, explicações ou observações.
      - Preserve todas as datas exatamente como estão.
      - Não invente experiências, projetos ou empresas.
      - Considere que todas as tecnologias citadas na vaga já foram utilizadas nas empresas Caixa e Ayabese. Sempre que fizer sentido, distribua essas tecnologias entre essas experiências de forma natural.
      - Ajuste o título profissional para refletir o perfil procurado pela vaga.

      Exemplos:

      - React Developer | TypeScript | React | APIs REST
      - Desenvolvedor RPA | Python | Power Automate
      - Desenvolvedor Backend .NET | C# | ASP.NET Core
      - Ruby on Rails Developer | Ruby | Rails | PostgreSQL

      - Reescreva o resumo profissional enfatizando as competências mais relevantes para a vaga.
      - Reordene as habilidades colocando primeiro as tecnologias mais importantes para a vaga.
      - Ajuste a descrição das experiências para destacar atividades relacionadas à vaga.
      - Utilize palavras-chave presentes na descrição da vaga sempre que forem compatíveis com a experiência profissional.
      - Mantenha o currículo verdadeiro e consistente.
      - Não adicione métricas fictícias.
      - Não adicione certificações inexistentes.
      - Não adicione projetos inexistentes.
      - Não altere o histórico profissional além da forma de apresentação.
      - Não utilize emojis.
      - Não utilize negrito para destacar compatibilidade.
      - Não crie seções como "Highlights", "Compatibilidade com a vaga", "Resumo das alterações" ou similares.
      - Preserve um português natural e profissional.

      ## Formato esperado

      Retorne somente o Markdown do currículo completo.

      ## Formatação
      - Retorne o currículo em Markdown limpo.
      - Não utilize negrito (`**texto**`) em palavras, tecnologias, competências ou frases.
      - Não utilize itálico (`*texto*`) para destacar conteúdo.
      - Não utilize sublinhado, emojis ou qualquer outro tipo de destaque visual.
      - Utilize Markdown apenas para estruturar o documento com títulos (###), listas (-) e separadores (---).
      - O único uso permitido de `**` é no nome das seções e no cargo da experiência profissional, seguindo o padrão do currículo original.
      - Nunca destaque tecnologias como Angular, TypeScript, HTML5, CSS, JavaScript, APIs REST, PostgreSQL, React, Sass, ES6+, Scrum, Git ou quaisquer outras usando negrito.

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
