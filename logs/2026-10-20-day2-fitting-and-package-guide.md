# 2026-10-20 handoff: Day 2 fitting workflow and package guide

## Goal

Day 2演習を、rootの `exercise.qmd` のようにコード・出力・解釈を順に説明できる
資料にする。講師が学生の様子を見て、新規推定と用意済み結果を選べるようにする。
必要以上の引数、分岐、説明を減らす。教材は英語、講師との連絡は日本語。

## Current state and decisions

- 編集元は `day2/exercise.qmd`。`R/generate_student_sources.R day2` で
  講師専用部分を除いた `exercise-student.qmd` を生成する。生成版を直接編集しない。
- 構成はモデル・データ → brms推定 → Stanコード・推定 → 結果読み込み →
  Summary → sampling diagnostics → trace plots → 生存確率 → 回帰図。
- 学生版に時間指定、Questions、回答欄、独立した課題を戻さない。
  講座独自のヘルパーではなく標準R関数を見せ、コードの横で解釈を説明する。
- `show_col_types=FALSE` は削除。新規推定のseedは両方とも42。
- brms式は `bf(suv | trials(n) ~ cons, center=FALSE)`。
  切片を含む一般的な `~ cons` の形を使い、内部中心化を止めてStanと事前分布を揃える。
  `class="b"` の独立normal(0, 2.5)が切片と傾きに適用されることを生成Stanで確認済み。
  consの標本平均は約−0.1908333なので、通常の内部中心化を使うと切片の事前分布が変わる。
- `0 + Intercept` と長い `result_source` / `if` による切り替えには戻さない。
- Data and posterior drawsは3つの独立したチャンク。
  `draws-brms`、`draws-stan`、`draws-precomputed` の一つだけ実行する。
  以降は共通の `coef_draws` と `sampler_diagnostics` を使う。
- brmsの読み込みはdraw変換・係数名変更とチェーンごとの発散数だけ。
  E-BFMIを手計算する長いコードは学生版から削除。
  brmsfitの内部 `$fit` はS4であり、CmdStanMCMCと同じ操作を前提にしない。
  公開APIの `brms::nuts_params()` を使う。
- 推定2チャンクとlive結果読み込み2チャンクは `eval=FALSE`。
  レンダリングは用意済み結果だけを使い、コンパイル・推定を実行しない。
- 手引き内の隠れたデータ一致チェックは削除し、保存結果とCSV・Stanの一致は
  `R/check_classroom_materials.R` で確認する。データ変更時は新規推定が必要。
- 現在のDay 2本編は19枚。R walkthroughと短いDay 3予告で終わる。
  PPCは補足。Interpretation in a real forest / Your research questionは削除済み。
  曲線の表示名は95% credible intervalのribbon。
- `classroom/PACKAGES.md` は最小限のインストールコードとCmdStanR案内に簡略化。
  tidyverse、posterior、bayesplot、patchwork、here、knitr、brms、cmdstanrを含む。
  日別用途の説明・表・参加方法の長い説明は戻さない。ログ作成時点の最新版は16行。

## Files changed in this work

- `day2/exercise.qmd` / `day2/exercise.html`：推定と3通りの結果読み込み、解説の簡略化。
- 生成された `day2/exercise-student.qmd` / `.html`：学生向け同内容（git管理外）。
- `day2/results.qmd`：保存結果の診断変数名とデータ読み込みを合わせた。
- `R/check_classroom_materials.R`：チャンク構成、モデル掲載内容、保存データ一致の確認。
- `README.md`、`classroom/instructor.md` / `.html`：一つの読み込みチャンクを選ぶ手順。
- `classroom/PACKAGES.md`：最小限のパッケージ案内。
- `dist/afec-classroom-materials.zip`：演習とパッケージ案内を再梱包済み。
  ただし下記の直近のPACKAGES.md変更との差分に注意。
- スライド・proposal等にも前段の未コミット変更がある。今回のログ保存では変更しない。

## Validation

- ローカル既存環境：R 4.6.1、brms 2.23.0、cmdstanr 0.9.0.9000、
  CmdStan 2.37.0、posterior 1.7.0、Quarto 1.10.19。依存の追加インストールなし。
- 最新のseed=42の学生コードを `/tmp` の別データコピーで実行。
  brmsとStanをそれぞれ4チェーン、warmup 1000・sampling 1000で新規推定。
  canonicalの `fits/` は上書きしていない。
- brms / Stan / preparedの全経路で係数表、診断、trace、81密度点の確率曲線を検証。
  各4000draw、R-hat <1.01、bulk/tail ESS >400、発散0。
  測定時間はbrms約8.8秒、Stan約5.3秒。授業サーバーでの実行時間保証ではない。
- 統合チェック：Day 1は3、Day 2は8、Day 3は10チャンクと保存済み7fitを確認。
  意図的な失敗fitは正常fitの閾値判定対象外。
- 演習の講師・学生HTML、results、講師ノートを再生成。
  Arcで学生HTMLの読み込みチャンク・コード・出力の表示を確認。
- ZIPを新規展開してDay 2の8チャンクを実行。QMD/HTMLの一致も確認済み。
- `git diff --check` は直前の編集完了時に合格。commit / pushはしていない。

再現用コマンド（R/Quarto実行時は `RENV_CONFIG_SANDBOX_ENABLED=FALSE`）：

```sh
Rscript R/generate_student_sources.R day2
Rscript R/check_classroom_materials.R
quarto render day2/exercise.qmd
quarto render day2/exercise-student.qmd
quarto render day2/results.qmd
quarto render classroom/instructor.md
Rscript R/build_classroom_materials.R --package-only
```

## Unresolved issues and next steps

- ログ作成時の読み取り確認で、現在の16行の `classroom/PACKAGES.md` と
  ZIP内の版が不一致。前回再梱包後に冒頭・末尾の案内が削除されている。
  最新ファイルを尊重し、配布前に `--package-only` を実行して一致を確認する。
  ログ保存だけの今回の操作では教材・ZIPを変更していない。
- 実際の授業用ブラウザーR環境の新規アカウント、同時コンパイル・推定負荷は未検証。
  学生にローカルCmdStan/C++/Docker導入を要求しない。用意済み結果を代替経路にする。
- renvのout-of-sync通知は既存。授業環境の検証とは分けて扱う。
- 次の作業は配布ZIPの差分反映と授業環境確認。推定コードの再設計やcanonical fitの
  再推定を繰り返す必要はない。
