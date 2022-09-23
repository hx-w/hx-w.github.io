---
title: 基于ID3算法的决策树实现
tags:
  - 算法
index_img: 'https://imgbed.scubot.com/ai.jpg'
abbrlink: 36aa
math: true
date: 2018-11-20 00:00:00
---

# Decision Tree

- name: He Xiang (贺翔) 

- date: 2018-11-10

- Experimental enviroment

  > OS: Windows 10
  >
  > IDE: Visual Studio 2017 & vim 8.1

------

<!--more-->
### Requirement

  ​    A decision tree is a flowchart-like structure in which each internal node represents a "test" on an attribute (e.g whether a coin flip comes up heads or tails), each branch represents the outcome of the test, and each leaf node represents a class label (decision taken after computing all attributes). The paths from root to leaf represent classification rules.

  ​    In Decision Tree the major challenge is the identification of the attribute for the root node in each level. This processis known as attribute selection. We have a popular attribute selection measure, Information Gain, which is defined based on entropy. Entropy is the measure of uncertainty of a random variable; it characterizes the impurity of an arbitrary collection of examples. As we use a node in decision tree to partition the training instances into smaller subsets, the entropy changes. Information gain is a measure of this change in entropy. The best attribute should maximize the information gain given a set of training instances. 

  ​    The table below specifies the conditions for whether to play badmintion or not. You are required to construct a decision tree based on the information in the table.

| No.  | Outlook  | Temperature | Humidity | Windy | Play? |
| ---- | -------- | ----------- | -------- | ----- | ----- |
| 1    | Sunny    | Hot         | High     | False | No    |
| 2    | Sunny    | Hot         | High     | True  | No    |
| 3    | Overcast | Hot         | High     | False | Yes   |
| 4    | Rain     | Mild        | High     | False | Yes   |
| 5    | Rain     | Cool        | Normal   | False | Yes   |
| 6    | Rain     | Cool        | Normal   | True  | No    |
| 7    | Overcast | Cool        | Normal   | True  | Yes   |
| 8    | Sunny    | Mild        | High     | False | No    |
| 9    | Sunny    | Cool        | Normal   | False | Yes   |
| 10   | Rain     | Mild        | Normal   | False | Yes   |
| 11   | Sunny    | Mild        | Normal   | True  | Yes   |
| 12   | Overcast | Mild        | High     | True  | Yes   |
| 13   | Overcast | Hot         | Normal   | False | Yes   |
| 14   | Rain     | Mild        | High     | True  | No    |

### Algorithm

The decision tree build is ruled by the ID3 algorithm(Iterative Dichotomiser 3). And its main theory is Information theory.

#### description

 If $X$ is a discrete random variable and its probability distribution is $p(x)=P(X=x), x\in X$, then the information entropy of $X$ is $H(X)$
$$
  H(X) = -\sum_{i}^{}{p(x_i)\log_2p(x_i)}
$$
  ​    $H(X)$ is also called Prior Entropy of X.

  ​    Support that condition that an event $y_j$ happens, the conditional probability of the random event $x_i$ occurring is $p(x_i\mid y_j)$. Under the condition of $y_j$, the uncertainty about $X$ is defined as the posterior entropy $H(X\mid y_j)$.
$$
  H(X|y_j)=-\sum_{i}^{}p(x_i|y_j)\log_2(p(x_i|y_j))
$$
  ​    For attribute $Y$ (the set of each $y_j$), the conditional entropy of set $X$ is $H(X\mid Y)$
$$
  H(X|Y)=\sum_{j}{p(y_j)H(X|y_j)}=-\sum_{j}{p(y_j)\sum_{i}{p(x_i|y_j)\log_2p(x_i|y_j)}}
$$
​      With prior entropy $H(X)$ and conditional entropy $H(X \mid Y)$, We can define the information gain $IG(X,Y)$, means that how much information gain can variable $X$ get from  attribute $Y$
$$
IG(X,Y)=H(X)-H(X|Y)
$$

#### example

For the training table. Consider attribute $Outlook=\{Sunny, Overcast,Rainy\}$.

  - $H(Play\mid Sunny)=-\frac{2}{5}\cdot\log_2\frac{2}{5}-\frac{3}{5}\cdot\log_2\frac{3}{5}=0.970951$
  - $H(Play \mid Overcast)=-\frac{4}{4}\cdot\log_2\frac{4}{4}-0\cdot\log_20=0$
  - $H(Play\mid Rainy)=-\frac{3}{5}\cdot\log_2\frac{3}{5}-\frac{2}{3}\cdot\log_2\frac{2}{3}=0.970951$

So the conditional entropy of $Outlook$ is $H(Play\mid Outlook)=\frac{5}{14}\cdot0.970951+\frac{4}{14}\cdot0+\frac{5}{14}\cdot0.970951=0.693536$. and then the information gain from $Outlook$ to $Play$ is $IG(Play,Outlook)=H(Play)-H(Play\mid Outlook)=0.24675$. 

  ​    For all attributes are the same:

- $IG(Play,Outlook)=0.24675$
- $IG(Play,Temperature)=0.0292226$
- $IG(Play, Humidity)=0.151836$
- $IG(Play, Windy)=0.048127$

  ​    Alfter get all attributes' IG, then choose the maximum IG. Here is $IG(Play, Outlook)$, For the decision tree current node, make $Outlook$ as the node's attribute and make all its value be the node's child nodes' index.

  ​    Divide the from when process the child node, and recursively build the tree.

###### class definition

```c++
  /**   
   * @Brief store the attribute(col) in the sample  
   */  
  class Attr {
  public:
      // which col  
      int colIndex;  
      // how many types of the attr
      int typeNum;  
      double conEntroy, InforGain;
      std::string attribute; 
      std::vector<std::string> attriValue;
      // init 0.0
      std::map<std::string, double> typeEntropy;
      // start from 1
      std::map<std::string, unsigned int> typeCnt;
      std::map<std::string, std::map<std::string, unsigned int> > attriValue_to_result;
  
      Attr(int col = 0, std::string str = ""):
          colIndex(col), typeNum(0), conEntroy(0), InforGain(0), attribute(str) { }
      ~Attr() { }
  };
  
  /**  
   * @Brief define the node infor
   */
  class TreeNode {
  public:
      // current attribute Infor
      std::string attri; 
      std::map<std::string, TreeNode *> attri_To_Children;
      std::vector<Attr> Table;
      int rowNum, colNum;
      double InforGain;
      int biggestIGidx;
      bool isLeaf;
  
      TreeNode(): biggestIGidx(0), InforGain(0.0),
      isLeaf(true), rowNum(0), colNum(0) { }
      ~TreeNode() { }
  
      void chooseIG();
      void clearCol();
  };
  
  /**  
   * @Brief define the decision tree
   */
  class DecisionTree {
  public:
      DecisionTree() { root = new TreeNode; }
      ~DecisionTree() { removeAll(root); }
  
      void BuildTree() { builder(root); }
      void ReadTable(std::ifstream &);
      void testTree() { testTreeHelp(root); }
      void printTree() { printTreeHelp(root, "NULL"); }; 
  private:
      void removeAll(TreeNode *);
      void printSample(TreeNode *);
      void computeEntropyFir(TreeNode *);
      void computeEntropySec(TreeNode *);
      void builder(TreeNode *);
      void processSample(TreeNode *);
      void divideChild(TreeNode *);
      void testTreeHelp(TreeNode *);
      void printTreeHelp(TreeNode *, std::string);
  
      TreeNode *root;
  };
```

### Analysis and discussion

​    ID3 algorithm is a kind of greedy algorithm, when set a node's attribute, alway choose the IG max one.

​    this algorithm is easy to train data, but there are also same disadvantages. First, it only can process descrete data, if data is continuous, it does not work. Second, this algorithm is very reply on the training data, so it is easy to build a insufficient decision tree. And at most time, there may be some attribute won't support any effective information, in this condition, the tree be built may be a bit unsuitable.

   For me to implement this algorithm, I use a lot of $STL$ like $string$, $map$ and $vector$, may waste a lot of space and make the time efficiency lower.


