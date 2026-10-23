# Day 3・Day 3-2：説明、事前分布への接続、配布資料の改訂

2026-10-23

## 目的と現在の状態

講師のレビューに沿って Day 3-2 の初学者向け説明を整理し、Day 3 の
事前分布と階層モデルのつながりを補強した。変更対象の HTML を再生成済み。
Day 3-2 の配布 ZIP も更新済み。新しいモデル推定、コミット、push、公開はしていない。

このログは既存の `2026-10-23-day3-2-research-computing.md` の続き。
同ログの「Quarto は任意」「ペア・口頭課題」「16枚」という初期方針は、
今回の講師指示で変更された。現在のソースと本ログを優先する。

## 維持すべき授業方針

- コンピュータに興味のない学生を想定し、説明は短く身近な英語にする。
  `.qmd` は **A document with text and R code**。Prose、executable などを
  学生向けの説明に使わない。必要な R 用語には簡単な意味を添える。
- コードと出力を一緒に読み進める。Discuss briefly、予想問題、ペアワーク、
  独立した課題としての指示を戻さない。
- Day 3-2 のスライド説明は最低限。補足は講師用ノートに残す。
- Quarto は必須。`here` だけが演習の Optional で、スライドには出さない。
- `getwd()`・`setwd()` を参加者の基本手順に使わず、Project を開いて
  相対パスで読む。検証用スクリプト内の作業ディレクトリ変更は別用途。

## Day 3-2 の変更と理由

- タイトルの priors.png 背景指定は Day 1–3 に既にあり、Day 3-2 にだけ不足。
  同じ指定を追加した。
- フォルダ図は実際の `day3-2/project/` を示す。ZIP 展開時のフォルダ名と区別。
- SSD の CSV を `read.csv()` で読み、代入した表を R の RAM 上で使うことを説明。
  元の CSV は書き換わらない。
- RStudio の画面構成だけを説明するスライドは削除。
- 絶対・相対パスは表に整理。Windows、macOS、Linux を別々に示す。
  列名は R's working directory。絶対パスは Anywhere、相対パスはこの例の
  Project folder。絶対パス自体の起点と実行時の作業フォルダを混同しない。
- 参考資料は別リポジトリ `phy-fun-div/diversity_example.qmd` の
  Using a relative path / Using here package / Avoiding absolute paths。
  `here` は演習の任意例だけに残し、`i_am()` と `here()` の役割を短く説明。
  `here()` が作る絶対パスと、個人の絶対パスを直接コードに書くことを区別する。
- 最終コード配色は **Material Dark 風**。`session.css` に局所指定し、
  共有テーマは変更していない。途中の「他の日と完全に共通化」は最終方針ではない。
- Project 名を **AFEC-R-basics** に統一。`.Rproj` を改名し、資料、ビルダー、
  検証スクリプト、ZIP 内の最上位フォルダも更新。ZIP ファイル自体の名前は
  `dist/afec-day3-2-materials.zip` のまま。
- 最終スライドは15枚。60分のうち45–55分がコードの読み合わせ、55–58分が
  必須 Quarto、58–60分がまとめ・質問。Quarto/knitr は授業環境に事前準備する。
  Render に問題が出た場合も、準備済み HTML で手順の説明は行う。

## Day 3 の変更と理由

- Today's progression を **Today's roadmap** に改題し、Today's objectives を削除。
  最終版は次の2項目と Key idea：
  1. Survival probabilities among mother trees — How can information from other trees improve our estimates?
  2. Species-specific regression relationships — How can the same idea be applied to intercepts and slopes?
  Key idea: Hierarchical models allow groups to share information.
- Slide 16 の既存図・回帰式に、種ごとの切片・傾きの共通正規事前分布を追加。
  **Shared priors let species share information: this is a hierarchical model.**
  main Slide 37 を独立した新規スライドとして挿入する案は採用しない。
- Slide 18 は単純化した独立の群事前分布を示していると明記し、相関を許すには
  多変量正規分布で切片・傾きを一緒に扱うと注記。
  群間の係数相関と、尤度から生じる事後依存は区別する。既存 vslope.stan は
  相関を含む実装であり、単純化した抜粋と同一モデルとは説明しない。
- 図の inspired by は削除。Conceptual simulation. References: と引用は残す。
- まとめは **main Slide 52 (Summary)** の本文をそのまま採用。
- 空間自己相関も main の図・式・本文をそのまま採用。画像パスだけ調整し、
  Optional の配置を維持。講師ノートには、内部セルの条件付き事前分布の例であり、
  完全な空間モデルには境界・同時分布・制約の指定が必要と補足した。
- Optional の Allometry and wood density / The same structure with a different response
  の2枚を削除。他の Optional スライドと保存 fit は残した。

## 主な変更ファイル

- `day3/slides.qmd` / `slides.html`。
- `day3-2/slides.qmd` / `.html`、`session.css`。
- `day3-2/exercise.qmd` / `.html`、生成学生用資料、生成 `project/R/inspect_seedlings.R`。
- `day3-2/instructor-notes.qmd` / `.html`、`README.md`、`coverage-assessment.md`。
- `day3-2/project/AFEC-R-basics.Rproj`（旧 AFEC-R-foundations.Rproj から改名）、
  `project/README.md`、`project/report.qmd` / `.html`。
- `scripts/build_day3_2.py`、`scripts/check_day3_2.R`。
- 既存ログ内の旧 Project 名も変更したが、本ログ作成時は既存ログを上書きしていない。

## 実行・確認結果

- `make day3-2` 相当で5文書を描画し、最新の ZIP を生成。
  改名後に `Rscript --vanilla scripts/check_day3_2.R` が PASS。
  別フォルダへの展開、Project ファイル、8行4列、型、欠測、ヒストグラム、
  入力不変、教員資料除外を確認。R 4.6.1、最終スクリプト実行は0.005秒。
- 演習の任意 `here` 例は here 1.0.2 で確認。相対パスとの読込結果一致、
  `R/` サブフォルダからの `i_am()` + `here()` による読込が PASS。
- Day 3 は変更のたびに `quarto render day3/slides.qmd` 相当を実行。
  最後の allometry 2枚削除後も成功。新しい推定は行っていない。
- main Slide 52 と空間自己相関の内容一致、画像パスの存在をソースで確認。
- Quarto 1.10.19。通常実行ではユーザーキャッシュへの書込制限で失敗したため、
  `/tmp` に置いた一時 Quarto ラッパーでキャッシュ先を変更した。
  RENV_PATHS_SANDBOX も一時フォルダに指定。インストール済み Quarto 本体や
  リポジトリのビルド手順は変更していない。一時ラッパーは永続的な依存ではない。

## 未確認事項と次の作業

- **このセッションの改訂版は目視未確認**。利用可能なブラウザがなく、
  レンダリング成功とソース確認まで。旧ログの Chrome 確認は改訂前の記録。
  次は Day 3 の Slide 16・18、復元したまとめ・空間スライドと、Day 3-2 全体の
  文字量・折返し・コード色・はみ出しをブラウザで確認する。
- ブラウザ RStudio の新規参加者アカウント、Quarto/knitr の事前準備、Render、
  同時接続、学生が読み進める所要時間は別途確認が必要。ローカル成功と区別する。
- Day 3 の instructor notes/冒頭コメントに、削除済み allometry 例への言及が
  一部残る。必要に応じて整理する。以前の `day3-2/validation.md` も初期状態の記録。
- Day 3 の全日程 ZIP・公開サイトは更新していない。配布・公開が必要なら、
  目視確認後に既存の packaging/site ワークフローを使う。
- 作業開始前からの変更を保持した。ルート `.gitignore` の変更と未追跡の
  `day3/.Rhistory` はこの依頼の成果物と一括して扱わず、commit 前に確認する。
- commit/push は未依頼。既存のユーザー変更を巻き戻さない。
