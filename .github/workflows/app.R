library(shiny)
library(plotly)
library(dplyr)

# 1. Questions data frame
questions <- data.frame(
  id = c(
    # Mòdul 1: Llar
    "m1_c1_to_child", "m1_child_to_c1", "m1_c2_to_child", "m1_child_to_c2",
    "m1_siblings_to_child", "m1_child_to_siblings", 
    # Mòdul 2: Escola
    "m2_teachers_to_child", "m2_child_to_teachers", "m2_friends_to_child", "m2_child_to_friends",
    # Mòdul 3: Comunitat
    "m3_community_friends_to_child", "m3_child_to_community_friends",
    "m3_community_adults_to_child", "m3_child_to_community_adults",
    # Mòdul 4: Família Extensa i Avis
    "m4_c1_parents_to_child", "m4_child_to_c1_parents",
    "m4_c2_parents_to_child", "m4_child_to_c2_parents",
    "m4_extended_family_to_child", "m4_child_to_extended_family"
  ),
  module = c(
    rep("MÒDUL 1: L'ENTORN DE LA LLAR", 6),
    rep("MÒDUL 2: ESCOLA / ESCOLA BRESSOL", 4),
    rep("MÒDUL 3: COMUNITAT LOCAL", 4),
    rep("MÒDUL 4: AVIS I FAMÍLIA EXTENSA", 6)
  ),
  type = c(rep("slider", 20)),
  question = c(
    # M1
    "1. Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza el/la CUIDADOR/A 1 cada llengua quan parla amb l'infant?",
    "2. Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza l'infant cada llengua quan parla amb el/la CUIDADOR/A 1?",
    "3. Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza el/la CUIDADOR/A 2 cada llengua quan parla amb l'infant? (Si no s'aplica, seleccioneu N/A)",
    "4. Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza l'infant cada llengua quan parla amb el/la CUIDADOR/A 2? (Si no s'aplica, seleccioneu N/A)",
    "5. Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitzen els GERMANS/ES cada llengua quan parlen amb l'infant? (Si no té germans/es, seleccioneu N/A)",
    "6. Pensa en una setmana típica de l'any actual. A casa, amb quina freqüència utilitza l'infant cada llengua quan parla amb els/les seus/seves GERMANS/ES? (Si no té germans/es, seleccioneu N/A)",
    # M2
    "7. Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitza el personal docent / educadors/es cada llengua quan parlen amb l'infant?",
    "8. Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitza l'infant cada llengua quan parla amb el personal docent / educadors/es?",
    "9. Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitzen els/les amics/gues cada llengua quan parlen amb l'infant?",
    "10. Pensa en una setmana típica de l'any actual. A l'escola / escola bressol, amb quina freqüència utilitza l'infant cada llengua quan parla amb els/les seus/seves amics/gues?",
    # M3
    "11. Pensa en una setmana típica de l'any actual. Quan l'infant està amb amics/gues a la comunitat local (fora de l'escola/escola bressol i fora de casa), amb quina freqüència utilitzen aquests/es amics/gues cada llengua quan parlen amb l'infant?",
    "12. Pensa en una setmana típica de l'any actual. Quan l'infant està amb amics/gues a la comunitat local (fora de l'escola/escola bressol i fora de casa), amb quina freqüència utilitza ell/ella cada llengua quan els parla?",
    "13. Pensa en una setmana típica de l'any actual. Quan l'infant està amb adults a la comunitat local (fora de l'escola/escola bressol i fora de casa), amb quina freqüència utilitzen aquests adults cada llengua quan parlen amb l'infant?",
    "14. Pensa en una setmana típica de l'any actual. Quan l'infant està amb adults a la comunitat local (fora de l'escola/escola bressol i fora de casa), amb quina freqüència utilitza ell/ella cada llengua quan els parla?",
    # M4
    "15. Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitzen els PARES DEL CUIDADOR/A 1 (avis de l'infant) cada llengua quan parlen amb l'infant?",
    "16. Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitza l'infant cada llengua quan parla amb els PARES DEL CUIDADOR/A 1 (avis)?",
    "17. Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitzen els PARES DEL CUIDADOR/A 2 (avis de l'infant) cada llengua quan parlen amb l'infant? (Si no s'aplica, seleccioneu N/A)",
    "18. Pensa en una setmana típica de l'any actual. Amb quina freqüència utilitza l'infant cada llengua quan parla amb els PARES DEL CUIDADOR/A 2 (avis)? (Si no s'aplica, seleccioneu N/A)",
    "19. Pensa en trobades o situacions habituals amb la FAMÍLIA EXTENSA (tiets/es, cosins/es, etc.). Amb quina freqüència utilitza aquesta família cada llengua quan parla amb l'infant?",
    "20. Pensa en trobades o situacions habituals amb la FAMÍLIA EXTENSA (tiets/es, cosins/es, etc.). Amb quina freqüència utilitza l'infant cada llengua quan parla amb la seva família extensa?"
  ),
  stringsAsFactors = FALSE
)

lang_colors <- c("Català" = "#D9534F", "Castellà" = "#F0AD4E", "Anglès" = "#5BC0DE")

# 2. UI Section
ui <- fluidPage(
  theme = shinythemes::shinytheme("flatly"),
  titlePanel("Qüestionari d'Ús Lingüístic"),
  
  sidebarLayout(
    sidebarPanel(
      width = 4,
      uiOutput("participant_display"),
      hr(),
      h4(uiOutput("module_title")),
      hr(),
      uiOutput("question_text"),
      br(),
      checkboxInput("na_option", "No s'aplica (N/A)", value = FALSE),
      hr(),
      uiOutput("dynamic_inputs"),
      br(),
      actionButton("next_btn", "Següent Pregunta", class = "btn-primary btn-block")
    ),
    
    mainPanel(
      width = 8,
      uiOutput("main_display")
    )
  )
)

# 3. Server Logic
server <- function(input, output, session) {
  
  current <- reactiveVal(1)
  participant_id <- reactiveVal("")
  
  # Reactive list to hold single-row wide responses
  responses_wide <- reactiveVal(list())
  
  # Show modal on startup to get Participant ID
  observe({
    showModal(modalDialog(
      title = "Identificació del Participant",
      p("Si us plau, introdueix el codi d'identificació de participant per començar:"),
      textInput("p_id_input", "ID del Participant:", value = ""),
      uiOutput("modal_error"),
      easyClose = FALSE,
      footer = actionButton("start_btn", "Començar Qüestionari", class = "btn-primary")
    ))
  })
  
  # Handle Participant ID input
  observeEvent(input$start_btn, {
    req_id <- trimws(input$p_id_input)
    if (req_id == "") {
      output$modal_error <- renderUI({
        p("El codi d'identificació no pot estar buit.", style = "color: red; font-weight: bold; margin-top: 10px;")
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
  
  # Display Participant ID on sidebar
  output$participant_display <- renderUI({
    req(participant_id())
    p(strong("ID Participant: "), span(participant_id(), style = "color: #2980B9; font-weight: bold;"))
  })
  
  q_info <- reactive({ questions[current(), ] })
  
  output$module_title <- renderUI({
    h4(q_info()$module, style = "color: #2C3E50; font-weight: bold;")
  })
  
  output$question_text <- renderUI({
    p(q_info()$question, style = "font-size: 16px; font-weight: 500;")
  })
  
  output$dynamic_inputs <- renderUI({
    if (q_info()$type == "numeric") {
      numericInput("weeks_num", "Setmanes de vacances:", value = 12, min = 0, max = 52)
    } else {
      tagList(
        sliderInput("cat", "Català (%)", min = 0, max = 100, value = 34),
        sliderInput("spa", "Castellà (%)", min = 0, max = 100, value = 33),
        sliderInput("eng", "Anglès (%)", min = 0, max = 100, value = 33)
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
    if (q_info()$type == "numeric") {
      tagList(
        h3("Nombre de setmanes"),
        p("Si us plau, introdueix el nombre exacte de setmanes al panell de l'esquerra.")
      )
    } else {
      tagList(
        plotlyOutput("pie", height = "450px"),
        h4(textOutput("total_info"), align = "center")
      )
    }
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
  
  # Download Handler triggering the native browser download
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
    current_data <- responses_wide()
    
    if (q_info()$type == "numeric") {
      current_data[[q_id]] <- ifelse(is.null(input$weeks_num), NA, input$weeks_num)
    } else {
      is_na <- isTRUE(input$na_option)
      
      # Dynamically add language suffix columns
      current_data[[paste0(q_id, "_cat")]] <- if (is_na) NA else input$cat
      current_data[[paste0(q_id, "_spa")]] <- if (is_na) NA else input$spa
      current_data[[paste0(q_id, "_eng")]] <- if (is_na) NA else input$eng
      current_data[[paste0(q_id, "_na")]]  <- is_na
    }
    
    responses_wide(current_data)
    
    if (current() < nrow(questions)) {
      current(current() + 1)
      updateCheckboxInput(session, "na_option", value = FALSE)
    } else {
      showModal(
        modalDialog(
          title = "Qüestionari Finalitzat",
          p("Gràcies per la seva col·laboració! Fes clic al botó inferior per descarregar les teves respostes en format CSV:"),
          br(),
          downloadButton("download_data", "Descarregar Resultats (CSV)", class = "btn-success btn-lg btn-block"),
          easyClose = FALSE,
          footer = NULL
        )
      )
    }
  })
}

shinyApp(ui, server)

#shinylive::export("C:/Users/HMC/OneDrive - UAB/Research/BiLS/Questionnaires", "site")
#httpuv::runStaticServer("site/")