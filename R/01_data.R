# ETAPE 1 — Import explicite et génération déterministe du cas Noria.
# Source pédagogique fictive : 240 tickets indépendants, un ticket par unité.
# Le générateur congruentiel et Box-Muller sont explicites pour permettre
# la reproduction à l'identique dans R et Python, sans dépendre d'un paquet.
make_noria <- function(seed = 20261023) {
  state <- as.double(seed)
  uniform <- function() {
    state <<- (16807 * state) %% 2147483647
    state / 2147483647
  }
  normal <- function() sqrt(-2 * log(uniform())) * cos(2 * pi * uniform())
  n <- 240L
  keys <- vapply(seq_len(n), function(i) uniform(), numeric(1))
  workflow <- rep("A", n)
  workflow[order(keys)[seq_len(n / 2)]] <- "B"
  complexity <- vapply(seq_len(n), function(i) 1L + floor(5 * uniform()), numeric(1))
  teams <- c("Atlas", "Boreal", "Cedre")
  team <- vapply(seq_len(n), function(i) teams[1L + floor(3 * uniform())], character(1))
  offsets <- c(Atlas = 0, Boreal = 3, Cedre = -2)
  duration <- vapply(seq_len(n), function(i) {
    round(max(5, 45 + 9 * complexity[i] - 8 * (workflow[i] == "B") +
                offsets[team[i]] + 12 * normal()), 1)
  }, numeric(1))
  # Satisfaction ordinale : les écarts entre notes ne sont pas supposés égaux.
  satisfaction <- vapply(seq_len(n), function(i) {
    max(1, min(5, floor(5.5 - duration[i] / 30 + 0.55 * normal() + 0.5)))
  }, numeric(1))
  satisfaction[seq(19, n, by = 19)] <- NA_real_
  reference <- data.frame(ticket_id = seq_len(n), workflow = workflow,
                          resolution_minutes = duration, complexity = complexity,
                          satisfaction = satisfaction, team = team)
  dirty <- reference
  dirty$resolution_minutes[c(21, 87, 154)] <- NA_real_
  dirty$resolution_minutes[203] <- -15
  dirty$team[c(5, 48, 101, 227)] <- paste0(" ", dirty$team[c(5, 48, 101, 227)], " ")
  dirty$workflow[c(11, 84, 195)] <- paste0(" ", dirty$workflow[c(11, 84, 195)], " ")
  dirty <- rbind(dirty, dirty[17, ])
  rownames(dirty) <- NULL
  list(reference = reference, dirty = dirty)
}

read_noria <- function(path = file.path("data", "noria_dirty.csv")) {
  # Le typage explicite rend le contrat indépendant des valeurs de la première ligne.
  utils::read.csv(path, stringsAsFactors = FALSE, na.strings = "",
                 colClasses = c("integer", "character", "numeric", "numeric",
                                "numeric", "character"), fileEncoding = "UTF-8")
}
