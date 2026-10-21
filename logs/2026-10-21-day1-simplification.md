# Day 1スライド・演習の簡略化とロゴ表示

2026-10-21

## 目的と現在の状態

Day 1を尤度、ベイズ更新、事後分布と不確実性の理解に集中させ、
Day 2のMCMC・事後サンプルの説明との重複を減らした。
各日のXTBGロゴは最初のスライドだけに表示する。
今回の教材修正は完了し、関連HTMLも再生成済み。配布ZIPと公開サイトは未更新。

## 決定と重要な発見

- `assets/course.css` に
  `.reveal:not(:has(#title-slide.present)) .slide-logo { display: none; }`
  を追加。3日とも同じCSSを参照するので、既存HTMLにも適用される。
  通常のスライド表示でタイトル以外のロゴが消えることをChromeで確認した。
- Day 1 Slide 2のbrowser-based Rという前提と、
  “The instructor may demonstrate live sampling.” を削除。
  supplied R code or figuresを使う表現に変更した。
- Slide 4の質問を “What if 40 out of 100 survived? Would we be more
  confident about p?” に変更。苗木の例を発展させ、Day 2でregression、
  Day 3でhierarchical modelsを学ぶ流れを明示した。
- Slide 8右側は、観測値とSDを固定し、muによって各点の密度とその積が変わり、
  この積をmuの関数として見ると尤度になる、という指定の説明に変更。
- 旧28–29枚目のposterior draws・summariesは最初に付録へ移したが、
  その後の指示で**Day 1のAppendix全体を削除**した。Referencesは最後に残した。
  付録や2枚のデモを戻さない。演習の後はまとめとReferencesへ進む。
- 結果シートからStan demonstrationを削除。MCMC、サンプルの生成と
  その確認・要約はDay 2で扱う。講師用Stan/brms資料は参考として残している。
- Slide 24には既に事後平均と95%信用区間がある。旧28–29を削除しても
  Day 1で分布の基本的な要約に触れられる。
- 90分は質問と余裕を含めた上限。通しの所要時間は未測定であり、90分を
  埋めるためのStanデモは追加しない。早く終われば既存の講師ガイドに従い進める。

## 最終的な演習

見出しは **Core exercise: More seedlings, less uncertainty?**。
参加者が調査数を考案する旧課題を、次の固定比較に置き換えた。

- Survey A: 2 survivors out of 5 seedlings
- Survey B: 20 survivors out of 50 seedlings
- Predict: どちらの事後分布が狭いか予想。
- Run: コードのyとNだけを変えて2つの事後分布を比較。
- Explain: 観測割合が同じなのに事後分布が異なる理由を説明。

コードはSurvey Aから開始し、一様事前分布と101点のグリッドは固定する。
Rが使えない場合は同じ2/5対20/50の結果図を読む。
旧4/10の例と、参加者用結果シートの別事前分布の節は削除した。
講師用の任意の事前分布比較は参考資料として残した。

連続事後分布はBeta(3,4)とBeta(21,31)。観測割合はどちらも0.4だが、
Survey Bは情報が多く、尤度が集中するため同じ事前分布のもとで事後分布も狭い。
平均は完全には一致しない。演習図は密度ではなくグリッド点ごとの確率なので、
図の高さより横幅を比較する。

## 変更ファイル

- `assets/course.css`: タイトルだけのXTBGロゴ表示。
- `day1/slides.qmd` / `.html`: 文面、演習、デモ・Appendix削除、References維持。
- `day1/exercise.qmd` / `.html`: 指定の簡潔な課題と実行コード。
- `day1/results.qmd`: 2/5対20/50の図と解釈、Stanデモ等の削除。
- `day1/instructor-notes.qmd` / `.html`: 固定比較に合わせた目的・解答と進行。
- `classroom/instructor.md` / `.html`: 同じ課題・進行への整合。
- 生成された `day1/exercise-student.qmd` / `.html` とresults HTML、
  図等も更新（生成物の一部はgitignored）。参加者ソースは直接編集していない。

開始時から存在したDay 1の変更（baijiuの同時確率の追記とコイン事前分布図の
subtitle等）は保持した。既存のexercise HTMLの差分も一括破棄していない。
モデル・データ・保存fitの変更や再推定はない。

## 確認と実行環境

- `RENV_CONFIG_SANDBOX_ENABLED=FALSE Rscript R/generate_student_sources.R day1`
  で解答なし参加者ソースを再生成。
- slides、exercise、exercise-student、results、instructor-notesと講師ガイドを
  描画。すべて終了コード0。描画で演習・結果図のコードも実行された。
- ChromeでSlide 4・8の文章、数式、レイアウトと、最終参加者演習の3項目・
  コード・図を目視確認。HTMLでAppendix削除とReferencesの維持も確認。
- 編集QMD/Markdownの `git diff --check` は通過。
  Quarto生成HTMLには自動生成コード由来の末尾空白が残る。
- R 4.6.1を使用。renvの一部キャッシュ欠損警告はあったが、描画に必要な
  既存パッケージで成功。インストールや修復は実施していない。
- 通常のQuarto起動はmacOSのユーザーキャッシュ内Sass DBの書込制限で失敗。
  XDG_CACHE_HOMEだけではmacOS版のキャッシュ先が変わらなかった。
  一時コピー `/tmp/afec-quarto-render.js` の `quartoCacheDir()` だけを
  `/tmp/afec-quarto-cache` に向けて描画した。インストール済みQuarto本体や
  プロジェクトの描画設定は変更していない。

最終描画に用いた呼出し（`/tmp` の一時ファイルは永続的な依存にしない）：

```sh
QUARTO_BIN_PATH=/Applications/quarto/bin \
QUARTO_SHARE_PATH=/Applications/quarto/share \
RENV_CONFIG_SANDBOX_ENABLED=FALSE \
/Applications/quarto/bin/tools/aarch64/deno run \
  --v8-flags=--enable-experimental-regexp-engine \
  --unstable-ffi --unstable-kv --no-config --no-lock --allow-all \
  /tmp/afec-quarto-render.js render day1/slides.qmd
```

## 未解決事項と次の作業

- **次は配布ZIPの再作成**。現在のDay 1限定ZIP・全日程ZIPには今回の修正が
  まだ入っていない。`make day1-zip` は再描画も行うため、通常環境のQuarto
  キャッシュ書込可否を確認する。公開サイトも別途更新が必要。
- Slide 24の “Peak: 0.4 (= MLE)” は、一様事前分布で一致する例。
  一般にMAPとMLEが一致するという意味にしない。
- 苗木は観測割合0.4、コインは表の割合0.6。別データだが同じ二項モデルと
  口頭で接続すると分かりやすい。
- 講師ガイド末尾等には旧browser RStudio環境を想定した準備項目が残る。
  今回はDay 1の参加者向け表現を修正した範囲であり、実際の配布・実行環境に
  合わせた全体の準備項目の見直しは未実施。
- 新規参加者環境、オフライン・Windows、教室の同時利用、実際の講義時間は
  今回確認していない。過去ログの検証と今回の変更後の検証を混同しない。
- 全教材チェックやlegacy targets、全モデル再推定は実行していない。
  commit/pushも行っていない。
