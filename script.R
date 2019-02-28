library(tidyverse)
library(readxl)
library(janitor)
library(gt)
library(fs)

download.file(url = "https://registrar.fas.harvard.edu/files/fas-registrar/files/class_enrollment_summary_by_term_2.28.19.xlsx", destfile = "reg_2019.xsls", mode = 'wb' )
download.file(url = "https://registrar.fas.harvard.edu/files/fas-registrar/files/class_enrollment_summary_by_term_03.06.18.xlsx", destfile = "reg_2018.xsls", mode = 'wb' )

x_2019 <- read_excel("reg_2019.xsls", skip = 3) %>% 
  clean_names() %>% 
  filter(!is.na(course_name)) %>% 
  select(course_id, course_title, course_name, u_grad, department)


x_2018 <- read_excel("reg_2018.xsls", skip = 3) %>% 
  clean_names() %>% 
  filter(!is.na(course_name)) %>% 
  select(course_id, course_title, course_name, u_grad, department)

fs::file_delete(c("reg_2019.xsls","reg_2018.xsls"))

inner_join(x_2019, x_2018, by = "course_id", suffix = c(".2019", ".2018")) %>% 
  mutate(change = u_grad.2019 - u_grad.2018) %>% 
  select(course_title.2019, course_name.2019, u_grad.2018, u_grad.2019, change) %>% 
  arrange(change) %>% 
  slice(1:10) %>% 
  gt %>% 
  tab_header(title = "Biggest Enrollment Decreases in Spring 2019") %>% 
  cols_label(course_title.2019 = "Number",
             course_name.2019 = "Name",
             u_grad.2019 = "2019",
             u_grad.2018 = "2018",
             change = "Change") %>% 
  tab_source_note("Data from the Harvard Registrar")


x_2019 %>% 
  anti_join(x_2018, by = 'course_id') %>% 
  arrange(desc(u_grad)) %>% 
  slice(1:10) %>%
  gt %>% 
  tab_header(title = "Biggest New Class in Spring 2019") %>% 
  cols_label(course_id = "ID",
             course_title = "Title",
             course_name = "Name",
             u_grad = "Enrollment") %>% 
  tab_source_note("Data from the Harvard Registrar")

