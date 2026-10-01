library(shiny)
library(plotly)
library(dplyr)
library(shinythemes)

# ------------------------------------------------------------------------------
# 1. Definició de les opcions de resposta habituals
# ------------------------------------------------------------------------------
likert_5_opts <- c(
  "Només en català",
  "Més en català",
  "Les dues llengües per igual",
  "Més en castellà",
  "Només en castellà"
)

profile_opts <- c(
  "Més catalanoparlant",
  "Més castellanoparlant",
  "Bilingüe totalment equilibrat"
)

identity_opts <- c(
  "Català",
  "Castellà",
  "Amb les dues per igual",
  "Amb cap de les dues"
)

# ------------------------------------------------------------------------------
# 2. Data frame amb totes les preguntes integrades
# ------------------------------------------------------------------------------
questions <- data.frame(
  id = c(
    "m0_child_name",
    "h06_home", "h06_extended", "h06_friends", "h06_school",
    "h612_home", "h612_extended", "h612_friends", "h612_school",
    "h1218_home", "h1218_extended", "h1218_friends", "h1218_school",
    "u1_friends", "u1_family", "u1_work", "u1_inner", "u1_math",
    "b1_origins", "b1_birth_year", "b1_gender", "b1_profile", "b1_identity",
    "b2_origins", "b2_birth_year", "b2_gender", "b2_profile", "b2_identity",
    "m1_c1_to_child", "m1_child_to_c1", "m1_c2_to_child", "m1_child_to_c2",
    "m1_siblings_to_child", "m1_child_to_siblings",
    "m2_teachers_to_child", "m2_child_to_teachers", "m2_friends_to_child", "m2_child_to_friends",
    "m3_community_friends_to_child", "m3_child_to_community_friends",
    "m3_community_adults_to_child", "m3_child_to_community_adults",
    "m4_c1_parents_to_child", "m4_child_to_c1_parents",
    "m4_c2_parents_to_child", "m4_child_to_c2_parents",
    "m4_extended_family_to_child", "m4_child_to_extended_family"
  ),
  module = c(
    "DADES INICIALS",
    rep("HISTORIAL LINGÜÍSTIC CUIDADOR/A: ESCOLA BRESSOL I INFANTIL (0-6 ANYS)", 4),
    rep("HISTORIAL LINGÜÍSTIC CUIDADOR/A: ESCOLA PRIMÀRIA (6-12 ANYS)", 4),
    rep("HISTORIAL LINGÜÍSTIC CUIDADOR/A: ESCOLA SECUNDÀRIA (12-18 ANYS)", 4),
    rep("ÚS ACTUAL DEL CATALÀ I CASTELLÀ (CUIDADOR/A)", 5),
    rep("INFORMACIÓ BIOGRÀFICA I D'IDENTITAT (CUIDADOR/A 1)", 5),
    rep("INFORMACIÓ BIOGRÀFICA I D'IDENTITAT (CUIDADOR/A 2 / PARELLA)", 5),
    rep("INFANT - MÒDUL 1: L'ENTORN DE LA LLAR", 6),
    rep("INFANT - MÒDUL 2: ESCOLA / ESCOLA BRESSOL", 4),
    rep("INFANT - MÒDUL 3: COMUNITAT LOCAL", 4),
    rep("INFANT - MÒDUL 4: AVIS I FAMÍLIA EXTENSA", 6)
  ),
  type = c(
    "text",
    rep("likert5", 4),
    rep("likert5", 4),
    rep("likert5", 4),
    rep("likert5", 5),
    "origin_group", "numeric", "text", "profile", "identity",
    "origin_group", "numeric", "text", "profile", "identity",
    rep("slider", 20)
  ),
  question = c(
    "Nom del fill/a del participant:",
    "Dels 0 als 6 anys, quina llengua solies fer servir a casa teva amb la teva família més propera?",
    "Dels 0 als 6 anys, quina llengua solies fer servir amb els teus parents que no vivien amb tu (p. ex. tiets, cosins)?",
    "Dels 0 als 6 anys, quina llengua solies fer servir amb els teus amics?",
    "Durant l'escola infantil, si s'escau, quina llengua solies fer servir amb els teus companys de classe?",
    "Durant l'escola primària, quina llengua solies fer servir a casa teva amb la teva família més propera?",
    "Durant l'escola primària, quina llengua solies fer servir amb els teus parents que no vivien amb tu (p. ex. tiets, cosins)?",
    "Durant l'escola primària, quina llengua solies fer servir amb els teus amics?",
    "Durant l'escola primària, quina llengua solies fer servir amb els teus companys de classe?",
    "Durant l'escola secundària, quina llengua solies fer servir a casa teva amb la teva família més propera?",
    "Durant l'escola secundària, quina llengua solies fer servir amb els teus parents que no vivien amb tu (p. ex. tiets, cosins)?",
    "Durant l'escola secundària, quina llengua solies fer servir amb els teus amics?",
    "Durant l'escola secundària, quina llengua solies fer servir amb els teus companys de classe?",
    "En una setmana típica, quant català/castellà fas servir quan et comuniques amb els teus amics més propers?",
    "En una setmana típica, quant català/castellà fas servir quan et comuniques amb la teva família?",
    "En una setmana típica, quant català/castellà fas servir quan et comuniques a la feina o universitat?",
    "Quan parles amb tu mateix(a) (diàleg intern), quant català/castellà fas servir?",
    "Quan fas càlculs mentalment, com fas servir el català/castellà per comptar?",
    "Indica la comarca (o província/comunitat autònoma si van créixer fora de Catalunya) on van créixer tu i la teva família:",
    "Quin any vas néixer? (Cuidador/a 1)",
    "Sexe / Gènere (Cuidador/a 1):",
    "En general, et consideres...",
    "Amb quina llengua t'identifies més?",
    "Indica la comarca (o província/comunitat autònoma) on van créixer el/la Cuidador/a 2 i la seva família:",
    "Quin any va néixer el/la Cuidador/a 2?",
    "Sexe / Gènere (Cuidador/a 2):",
    "En general, consideres que el/la cuidador/a 2 és...",
    "Amb quina llengua consideres que s'identifica més el/la cuidador/a 2?",
    "Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza el/la CUIDADOR/A 1 cada llengua quan parla amb l'infant?",
    "Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza l'infant cada llengua quan parla amb el/la CUIDADOR/A 1?",
    "Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza el/la CUIDADOR/A 2 cada llengua quan parla amb l'infant?",
    "Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza l'infant cada llengua quan parla amb el/la CUIDADOR/A 2?",
    "Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitzen els GERMANS/ES cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza l'infant cada llengua quan parla amb els/les seus/seves GERMANS/ES?",
    "Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitza el personal docent / educadors/es cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitza l'infant cada llengua quan parla amb el personal docent / educadors/es?",
    "Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitzen els/les amics/gues cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitza l'infant cada llengua quan parla amb els/les seus/seves amics/gues?",
    "Pensa en una setmana típica de l'any actual. Quan l'infant està amb amics/gues a la comunitat local, amb quina freqüència utilitzen aquests/es amics/gues cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. Quan l'infant està amb amics/gues a la comunitat local, amb quina freqüència utilitza ell/ella cada llengua quan els parla?",
    "Pensa en una setmana típica de l'any actual. Quan l'infant està amb adults a la comunitat local, amb quina freqüència utilitzen aquests adults cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. Quan l'infant està amb adults a la comunitat local, amb quina freqüència utilitza ell/ella cada llengua quan els parla?",
    "Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitzen els PARES DEL CUIDADOR/A 1 cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitza l'infant cada llengua quan parla amb els PARES DEL CUIDADOR/A 1?",
    "Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitzen els PARES DEL CUIDADOR/A 2 cada llengua quan parlen amb l'infant?",
    "Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitza l'infant cada llengua quan parla amb els PARES DEL CUIDADOR/A 2?",
    "Pensa en trobades o situacions habituals amb la FAMÍLIA EXTENSA. Amb quina freqüència utilitza aquesta família cada llengua quan parla amb l'infant?",
    "Pensa en trobades o situacions habituals amb la FAMÍLIA EXTENSA. Amb quina freqüència utilitza l'infant cada llengua quan parla amb la seva família extensa?"
  ),
  stringsAsFactors = FALSE
)

lang_colors <- c("Català" = "#D9534F", "Castellà" = "#F0AD4E", "Anglès" = "#5BC0DE")

# ------------------------------------------------------------------------------
# 3. Interfície d'Usuari (UI)
# ------------------------------------------------------------------------------
ui <- fluidPage(
  theme = shinythemes::shinytheme("flatly"),
  titlePanel("Enquesta Lingüística per a Bilingües i Ús en l'Infant"),
  
  sidebarLayout(
    sidebarPanel(
      width = 5,
      uiOutput("participant_display"),
      hr(),
      uiOutput("module_title"),
      hr(),
      uiOutput("question_text"),
      br(),
      uiOutput("na_checkbox_ui"),
      hr(),
      uiOutput("dynamic_inputs"),
      br(),
      actionButton("next_btn", "Següent Pregunta", class = "btn-primary btn-block")
    ),
    
    mainPanel(
      width = 7,
      uiOutput("main_display")
    )
  )
)

# ------------------------------------------------------------------------------
# 4. Lògica del Servidor (Server)
# ------------------------------------------------------------------------------
server <- function(input, output, session) {
  
  current <- reactiveVal(1)
  participant_id <- reactiveVal("")
  responses_wide <- reactiveVal(list())
  
  observe({
    showModal(modalDialog(
      title = "Identificació del Participant",
      p("Si us plau, introdueix el codi o nom del participant (Cuidador/a 1) per començar:"),
      textInput("p_id_input", "Nom / ID del Participant:", value = ""),
      uiOutput("modal_error"),
      easyClose = FALSE,
      footer = actionButton("start_btn", "Començar Qüestionari", class = "btn-primary")
    ))
  })
  
  observeEvent(input$start_btn, {
    req_id <- trimws(input$p_id_input)
    if (req_id == "") {
      output$modal_error <- renderUI({
        p("El camp no pot estar buit.", style = "color: red; font-weight: bold; margin-top: 10px;")
      })
    } else {
      participant_id(req_id)
      responses_wide(list(
        participant_id = req_id,
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      ))
      removeModal()
    }
  })
  
  output$participant_display <- renderUI({
    req(participant_id())
    p(strong("Participant: "), span(participant_id(), style = "color: #2980B9; font-weight: bold;"))
  })
  
  q_info <- reactive({ questions[current(), ] })
  
  output$module_title <- renderUI({
    h4(q_info()$module, style = "color: #2C3E50; font-weight: bold;")
  })
  
  output$question_text <- renderUI({
    p(q_info()$question, style = "font-size: 16px; font-weight: 500;")
  })
  
  output$na_checkbox_ui <- renderUI({
    if (q_info()$type == "slider") {
      checkboxInput("na_option", "No s'aplica (N/A)", value = FALSE)
    } else {
      NULL
    }
  })
  
  output$dynamic_inputs <- renderUI({
    type <- q_info()$type
    q_id <- q_info()$id
    
    if (type == "slider") {
      tagList(
        sliderInput("cat", "Català (%)", min = 0, max = 100, value = 34),
        sliderInput("spa", "Castellà (%)", min = 0, max = 100, value = 33),
        sliderInput("eng", "Anglès (%)", min = 0, max = 100, value = 33)
      )
    } else if (type == "likert5") {
      radioButtons("resp_likert5", "Selecciona una opció:", choices = likert_5_opts, selected = character(0))
    } else if (type == "profile") {
      radioButtons("resp_profile", "Selecciona una opció:", choices = profile_opts, selected = character(0))
    } else if (type == "identity") {
      radioButtons("resp_identity", "Selecciona una opció:", choices = identity_opts, selected = character(0))
    } else if (type == "numeric") {
      numericInput("resp_numeric", "Any de naixement:", value = 1985, min = 1930, max = 2026)
    } else if (type == "text") {
      textInput("resp_text", "Resposta:", value = "")
    } else if (type == "origin_group") {
      prefix <- ifelse(q_id == "b1_origins", "b1", "b2")
      tagList(
        p(em("Escriu la comarca o província/comunitat autònoma:")),
        textInput(paste0(prefix, "_subject"), "Persona avaluada (Tu / Cuidador 2):", value = ""),
        textInput(paste0(prefix, "_mother"), "Mare:", value = ""),
        textInput(paste0(prefix, "_father"), "Pare:", value = ""),
        textInput(paste0(prefix, "_mat_gm"), "Àvia materna:", value = ""),
        textInput(paste0(prefix, "_mat_gf"), "Avi matern:", value = ""),
        textInput(paste0(prefix, "_pat_gm"), "Àvia paterna:", value = ""),
        textInput(paste0(prefix, "_pat_gf"), "Avi patern:", value = "")
      )
    }
  })
  
  pie_values <- reactive({
    req(q_info()$type == "slider")
    if (isTRUE(input$na_option)) return(c(Català = 0, Castellà = 0, Anglès = 0))
    
    raw <- c(
      Català = ifelse(is.null(input$cat), 34, input$cat),
      Castellà = ifelse(is.null(input$spa), 33, input$spa),
      Anglès = ifelse(is.null(input$eng), 33, input$eng)
    )
    tot <- sum(raw)
    if (tot == 0) return(c(Català = 0, Castellà = 0, Anglès = 0))
    round((raw / tot) * 100, 1)
  })
  
  output$main_display <- renderUI({
    if (q_info()$type == "slider") {
      tagList(
        plotlyOutput("pie", height = "450px"),
        h4(textOutput("total_info"), align = "center")
      )
    } else {
      wellPanel(
        h3("Informació de la Secció", style = "color: #2C3E50;"),
        p("Si us plau, respon a les qüestions indicades al formulari de l'esquerra per continuar amb el qüestionari."),
        hr(),
        p(strong("Pregunta actual: "), textOutput("current_q_num", inline = TRUE))
      )
    }
  })
  
  output$current_q_num <- renderText({
    paste(current(), "de", nrow(questions))
  })
  
  output$total_info <- renderText({
    if (isTRUE(input$na_option)) return("Marcat com a N/A (No s'aplica)")
    raw_sum <- sum(c(input$cat, input$spa, input$eng))
    paste0("Suma dels lliscadors: ", raw_sum, "% (Ajustat automàticament al 100% al gràfic)")
  })
  
  output$pie <- renderPlotly({
    vals <- pie_values()
    df <- data.frame(Llengua = names(vals), Percentatge = as.numeric(vals))
    
    plot_ly(
      df, labels = ~Llengua, values = ~Percentatge, type = "pie",
      textinfo = "label+percent", hoverinfo = "label+percent",
      marker = list(colors = unname(lang_colors[names(vals)]))
    ) %>%
      layout(
        title = list(text = "Proporció d'Ús Lingüístic", font = list(size = 18)),
        showlegend = TRUE
      )
  })
  
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("Language_Questionnaire_", participant_id(), "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      df_export <- as.data.frame(responses_wide(), stringsAsFactors = FALSE)
      write.csv(df_export, file, row.names = FALSE)
    }
  )
  
  observeEvent(input$next_btn, {
    q_id <- q_info()$id
    type <- q_info()$type
    current_data <- responses_wide()
    
    if (type == "slider") {
      is_na <- isTRUE(input$na_option)
      if (is_na) {
        current_data[[paste0(q_id, "_cat")]] <- NA
        current_data[[paste0(q_id, "_spa")]] <- NA
        current_data[[paste0(q_id, "_eng")]] <- NA
      } else {
        vals <- pie_values()
        current_data[[paste0(q_id, "_cat")]] <- vals[["Català"]]
        current_data[[paste0(q_id, "_spa")]] <- vals[["Castellà"]]
        current_data[[paste0(q_id, "_eng")]] <- vals[["Anglès"]]
      }
      current_data[[paste0(q_id, "_na")]]  <- is_na
    } else if (type == "likert5") {
      current_data[[q_id]] <- ifelse(is.null(input$resp_likert5), NA, input$resp_likert5)
    } else if (type == "profile") {
      current_data[[q_id]] <- ifelse(is.null(input$resp_profile), NA, input$resp_profile)
    } else if (type == "identity") {
      current_data[[q_id]] <- ifelse(is.null(input$resp_identity), NA, input$resp_identity)
    } else if (type == "numeric") {
      current_data[[q_id]] <- ifelse(is.null(input$resp_numeric), NA, input$resp_numeric)
    } else if (type == "text") {
      current_data[[q_id]] <- ifelse(is.null(input$resp_text), NA, input$resp_text)
    } else if (type == "origin_group") {
      prefix <- ifelse(q_id == "b1_origins", "b1", "b2")
      current_data[[paste0(prefix, "_origin_subject")]] <- input[[paste0(prefix, "_subject")]]
      current_data[[paste0(prefix, "_origin_mother")]]  <- input[[paste0(prefix, "_mother")]]
      current_data[[paste0(prefix, "_origin_father")]]  <- input[[paste0(prefix, "_father")]]
      current_data[[paste0(prefix, "_origin_mat_gm")]]  <- input[[paste0(prefix, "_mat_gm")]]
      current_data[[paste0(prefix, "_origin_mat_gf")]]  <- input[[paste0(prefix, "_mat_gf")]]
      current_data[[paste0(prefix, "_origin_pat_gm")]]  <- input[[paste0(prefix, "_pat_gm")]]
      current_data[[paste0(prefix, "_origin_pat_gf")]]  <- input[[paste0(prefix, "_pat_gf")]]
    }
    
    responses_wide(current_data)
    
    if (current() < nrow(questions)) {
      current(current() + 1)
      if (is.element("na_option", names(input))) {
        updateCheckboxInput(session, "na_option", value = FALSE)
      }
    } else {
      df_export <- as.data.frame(responses_wide(), stringsAsFactors = FALSE)
      local_file <- "responses_database.csv"
      
      tryCatch({
        if (!file.exists(local_file)) {
          write.csv(df_export, local_file, row.names = FALSE)
        } else {
          write.table(df_export, local_file, append = TRUE, sep = ",", col.names = FALSE, row.names = FALSE)
        }
        
        showModal(
          modalDialog(
            title = "Qüestionari Finalitzat",
            p("Gràcies per la seva col·laboració! Les teves respostes s'han desat automàticament al fitxer local."),
            br(),
            downloadButton("download_data", "Descarregar Còpia Local (CSV)", class = "btn-success btn-lg btn-block"),
            easyClose = FALSE,
            footer = NULL
          )
        )
      }, error = function(e) {
        showModal(
          modalDialog(
            title = "Atenció: Error en desar el fitxer",
            p("No s'han pogut desar les dades al fitxer local automàticament."),
            p(span(e$message, style = "color: red;")),
            br(),
            downloadButton("download_data", "Descarregar Resultats en CSV", class = "btn-warning btn-lg btn-block"),
            easyClose = FALSE,
            footer = NULL
          )
        )
      })
    }
  })
}

# ------------------------------------------------------------------------------
# 5. Execució de l'aplicació
# ------------------------------------------------------------------------------
