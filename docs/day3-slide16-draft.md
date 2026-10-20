# Day 3 slide 16: draft for review

## 改訂の意図

主題は、**説明変数を使わずにグループごとの生存確率を推定するモデルから、
密度によって生存確率が変わる回帰モデルへの拡張**。
母樹から種への変更は、応用例の変更として補足する。

聴衆が説明できるようにしたいこと：密度を説明変数として加えると、
グループごとに一つの確率を推定する代わりに、切片と傾きで生存曲線を表す。
その回帰係数にも、ここまで学んだ情報共有を適用できる。

## Slide 16 — proposed audience-facing content

### From an intercept-only model to regression

**So far: intercept only**

$$
\operatorname{logit}(p_j) = \alpha_j
$$

One survival probability per group, with no density predictor.

**Now: intercept + density effect**

$$
\operatorname{logit}(p_{ij}) = \alpha_j + \beta_j x_{ij}
$$

Adding a density predictor lets survival probability change within each group.

**We can share information about these coefficients, too.**

## 図と配置の案

- 左：上の二つのモデルを縦に並べ、追加した項
  $\beta_j x_{ij}$ を強調する。
- 右：既存の密度–生存曲線の図を使う。各曲線が一つのグループを表すと説明する。
- 下：回帰係数についても情報共有できる、という一文を置く。
- 母樹と種の違い、文献、図が概念説明用であることは短い補足にする。

## Speaker notes — proposed wording

So far, each group had one survival probability. We did not include a predictor
that could explain variation in survival within a group.

Now bring back Day 2's question: how does survival change with conspecific
density? Adding density gives us a regression. Each group is described by a
curve, with an intercept and a density coefficient.

The information-sharing idea still applies. Instead of connecting only the
group survival probabilities, we can connect the group regression coefficients
through shared distributions.

For this application, the groups are species rather than mother trees. These
curves illustrate a different simulated example; they are not a new fit to the
eight mother trees. The important extension is the addition of a predictor.

## 次のスライドへのつなぎ方

現行スライド17は、密度回帰を導入した直後に「種の個体数で傾きを説明する」
という追加の説明変数まで導入している。まずは切片・密度係数の情報共有を示し、
その後に個体数との関係へ進む案とする。

次のスライドで扱う問い：**How can groups share information about their curves?**

例えば、切片と傾きそれぞれに共有分布を置く構造を示す。

$$
\alpha_j \sim \mathcal{N}(\mu_\alpha, \sigma_\alpha),
\qquad
\beta_j \sim \mathcal{N}(\mu_\beta, \sigma_\beta)
$$

ここでは第2引数を標準偏差とし、切片・傾きのグループ間の相関を含めない
簡単な構造を仮定する。完全なモデルには超パラメータの事前分布も必要。
実装や新たな推定は追加せず、構造の説明に留める。

厳密には、これまでのモデルも切片だけのロジスティック回帰と解釈できる。
したがって講師の説明では「回帰ではないモデルから回帰へ」ではなく、
「説明変数なしから、密度を説明変数に含む回帰へ」と区別する。

## 状態

スライド16は承認済みの内容を反映し、HTMLを再生成・表示確認済み。
後続の教材改訂で、比較図の後にintercept-only modelのコード読解を配置。
回帰への復帰後は、varying intercepts、varying slopes、group-level predictorを
順に説明するスライドを追加。新規推定や参加者の実装課題は追加しない。

後続改訂：モデル読解を、Stan全文・推定・事後分布・診断・事後予測チェックを
含む分析例に拡充。時間配分とBefore you beginは掲載しない。
