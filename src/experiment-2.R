library(R6)

Experiment_2 <- R6Class("Experiment",
  public=list(
    note = NA,
    log_dir = NA,
    params = NA,
    model=NA,
    obs=NA,
    epenthesis=NA,
    Z_true = NA,
    prediction=NA,
    param_names = c("n_parallel", "algorithm", "lang",'bias', "sds", "coart"),
    lang_names = c("jpn-u", "bpt-i"),
    # init
    initialize = function(params, log_dir="./log") {
      self$params = params
      stopifnot(setequal(names(params), self$param_names))
      stopifnot(params$lang %in% self$lang_names)
      self$log_dir <- log_dir
      self$model <- self$make_model(params)  # make model for each trial
      self$obs <- self$make_obs(params)
      # self$evidence <- 'ebuzo'  # epenthesis ならこっちだけでいい
    },
    make_model = function(params){
      categories <- unname(unlist(read.table(file = "../data/categories_2011.txt")))
      priors <- unname(unlist(read.table(file = "../data/pi_2011.txt"))) # これはかわらない. i=1のときのみだから
      priors = priors/sum(priors)
      names(priors) = categories
      # SET LANGUAGE
      # ここでAにバイアスをかける
      A_mat <- as.matrix(read.table(file = "../data/alpha_2011.txt"))  # 2つの言語で子音感の遷移はない.
      bias = params$bias
      # TODO: u/iの位置のハードコーディングをやめる
      if (params$lang=='jpn-u') bias = matrix(rep(c(1, 1, 1+bias, 1, 1, 1), 6), ncol = 6, byrow = TRUE)  # uにバイアス
      if (params$lang=='bpt-i') bias = matrix(rep(c(1, 1, 1, 1, 1, 1+bias), 6), ncol = 6, byrow = TRUE)  # iにバイアス
      A_mat = A_mat * bias
      A_mat = A_mat/rowSums(A_mat)  
      # SET STANDARD DEVIATION (uやiのかぶり具合)
      B_params <- as.matrix(read.table(file = "../data/b_params_2011.txt", header = TRUE, sep = " "))
      # ここで音響モデルの分散を増す(音素の守備範囲を広くする)
      if (params$lang=='jpn-u')  B_params[,'sd'] = B_params[,'sd'] + c(0,0,params$sds,0,0,0)
      if (params$lang=='bpt-i')  B_params[,'sd'] = B_params[,'sd'] + c(0,0,0,0,0,params$sds) 
      B_list <- lapply(categories, function(cat) B$new(src = cat, mu = B_params[cat, "mu"], sd = B_params[cat, "sd"]))
      names(B_list) = categories
      # SET N_PARALLEL and ALGORITHM
      model_experiment = HMM$new(states = categories,
                                 priors = priors,
                                 A = A_mat,
                                 B = B_list,
                                 n_parallel = params$n_parallel,
                                 algorithm = params$algorithm)
      return(model_experiment)
    },
    make_obs = function(params, coart=NULL){
      es = self$model$B[["e"]]$rvs(2)
      # 実験1との違い. 調音結合を入れる
      if (params$coart=="natural"){ bs = self$model$B[["b"]]$rvs(2)}
      else{ bs = self$get_coart(n=2, target_c = 'b', target_v=params$coart) }
      zs = self$model$B[["z"]]$rvs(2)
      os = self$model$B[["o"]]$rvs(2)
      obs = c(es,bs,zs,os)
      stopifnot(length(obs) == 8)
      return(obs)
    },
    get_coart = function(n, target_c, target_v, n_rand=1000){
      # target_c が最も target_v が二番目に尤度が高いサンプルを n 作成する
      # 実験2では /b/の音響的な手がかりに注意. iなら/b/だが/i/の確率が/u/の確率より高い
      candidates = self$model$B[[target_c]]$rvs(n_rand)
      coarts = c()
      for (candy in candidates){
        proba = self$model$b_i(candy)
        proba = self$model$keep_n_best(proba, 2) #  上から1,2しか見ないのでほかは潰してよい
        c_lt_v = (proba[target_c] > proba[target_v])  # 子音が母音より尤もらしい
        is_target_v = proba[target_v] != 0  # 母音の確率はkeep_n_best 後でも0でもない
        if(c_lt_v &is_target_v) {coarts = c(coarts, candy ) }
        if (length(coarts)==n) break
      }
      if(! length(coarts) == n) print(cat(n, target_c, target_v))
      stopifnot(length(coarts) == n)  # 通らない場合条件を満たすサンプルが得られていない. bの分布かn_randを変える
      return(coarts)
    },
    run = function() {
      # ここが変わる
      Z_hat = unique_seq(self$model$decode(self$obs))
      self$prediction = paste(Z_hat, collapse = "")
      # TODO: self$model$decode(self$obs) も記録. 日本語母語話者で /i/ が挿入されているため
      # TODO: 逆向きで認識させて前からバックトレースすれば並列処理はいらなくなり serialでも再現できる?
      if(self$prediction == "ebuzo") self$epenthesis = "u"
      if(self$prediction == "ebizo") self$epenthesis = "i"
      if(self$prediction == "ebzo") self$epenthesis = "no vowel"
      # other case will be NA
    },
    save = function(tgt) {
      return(NA)
    },
    print = function(...) {
    }
  )
)