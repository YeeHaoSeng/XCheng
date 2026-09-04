---
title: Acwing 算法基础课 chapter 3  
cover:
  image: /img/acwing.png  
date: 2022-08-08T01:13:17+08:00
lastmod: 2026-07-31T00:00:00+08:00
draft: false
remark: 2022-03-03 - 2022-08-08
description: lecture 3 搜索与图论
tags:        
  - Acwing算法基础课   
---

# lecture 3 搜索与图论

## DFS

![BFS&DFS](/img/acwing/chapter3/image-20220303233243772.png)

```cpp
int dfs(int u)
{
    st[u] = true; // st[u] 表示点u已经被遍历过

    for (int i = h[u]; i != -1; i = ne[i])
    {
        int j = e[i];
        if (!st[j]) dfs(j);
    }
}
```

### [842. 排列数字 - AcWing题库](https://www.acwing.com/problem/content/844/)

给定一个整数 n，将数字 1∼n 排成一排，将会有很多种排列方法。现在，请你按照字典序将所有的排列方法输出。

**输入样例**

```cpp
3
```

**输出样例**

```cpp
1 2 3
1 3 2
2 1 3
2 3 1
3 1 2
3 2 1
```

**解析**

DFS：此题 "暴搜" ，首先应考虑以什么样的 **顺序** 搜索。

`if(n == 3)`

![DFS](/img/acwing/chapter3/image-20220303234411488-16608868431321.png)

![DFS](/img/acwing/chapter3/image-20220303234606743-16608873742005.png)

注：

1. 每一次只会存当前路径，回溯的时候系统即已释放。
2. 回溯之后记得 **恢复现场** 。

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N = 10;
int n,path[N],st[N];

void dfs(int u)
{
    if(u > n)   
    {
        for(int i = 1;i <= n;++i)   printf("%d ",path[i]);
        puts("");
        return;
    }
    for(int i = 1;i <= n;++i)
    {
        if(!st[i])
        {
            st[i] = 1;
            path[u] = i;
            dfs(u+1);
            // path[u] = 0;     //可不用恢复,自动覆盖
            st[i] = 0;
        }
    }
}

int main()
{
    scanf("%d", &n);
    dfs(1);
    return 0;
}

//或者	结合位运算判别是否已选
#include<bits/stdc++.h>
using namespace std;
const int N = 10;
int n,path[N];

void dfs(int u,int state)
{
    if(u > n)   
    {
        for(int i = 1;i <= n;++i)   printf("%d ",path[i]);
        puts("");
        return;
    }
    for (int i = 1; i <= n; i ++ )
        if (!(state >> i & 1))
        //考虑state的二进制表示，如果第i位是1，表示当前数已经被用过了，否则表示没被用过。所以如果i已经被用过了，则需要跳过。
        //state不是数组，在每层里面没有修改过state，相当于st[i]在回溯之后就自动变成false了。
        {
            path[u] = i ;
            dfs(u + 1, state + (1 << i));
        }
}

int main()
{
    scanf("%d", &n);
    dfs(1,1);
    return 0;
}
```



### [843. n-皇后问题 - AcWing题库](https://www.acwing.com/problem/content/845/)

n−皇后问题是指将 n 个皇后放在 n×n 的国际象棋棋盘上，使得皇后不能相互攻击到，即任意两个皇后都不能处于同一行、同一列或同一斜线上。现在给定整数 n，请你输出所有的满足条件的棋子摆法。

**输入样例**

```cpp
4
```

**输出样例**

```cpp
.Q..
...Q
Q...
..Q.

..Q.
Q...
...Q
.Q..
```

**解析**

剪枝：如若当前方案已不可行，不必再往下搜。

两条对角线(对角线长度为2n-1)：

![dg&udg](/img/acwing/chapter3/image-20220304230046330.png)

对角线：

![对角线](/img/acwing/chapter3/image-20220305171115034.png)

为了防止`y-x`为复数，再加上 `n` 。

**第一种搜索顺序**

```cpp
//按行枚举，保证每行只有一个，无需row
//u表示第u行，i表示第i列
#include<bits/stdc++.h>
using namespace std;
const int N = 20;
int n;
char g[N][N];
bool col[N],dg[N],udg[N];

void dfs(int u)
{
    if(u == n)
    {
        for(int i = 0;i < n;++i)    
        {            
            for(int j = 0;j < n;++j)
            {
                printf("%c",g[i][j]);
            }
            puts("");
        }
        puts("");
    }

    for(int i = 0;i < n;++i)
    {
        if(!col[i] && !dg[u+i] && !udg[u-i+n])
        {
            g[u][i] = 'Q';
            col[i] = dg[u+i] = udg[u-i+n] = true;
            dfs(u+1);
            //恢复
            g[u][i] = '.';
            col[i] = dg[u+i] = udg[u-i+n] = false;
        }
    }

}

int main()
{
    cin >> n;
    for(int i = 0;i < n;++i)
    {
        for(int j = 0;j < n;++j)
        {
            g[i][j] = '.';
        }
    }
    dfs(0);
    return 0;
}
```

**第二种搜索顺序**

比起上述提炼行优化，此法更原始。结合行逐项来考虑，也可以写成如下。

![n皇后](/img/acwing/chapter3/image-20220322220511867.png)

x y 为坐标，s 为皇后。每次枚举完当前格子，转移到下一个格子，一行最后一格换行。

x = n 即枚举完最后一行，停止。如果摆了n个皇后，输出。

```cpp
//（DFS按每个元素枚举）时间复杂度O(2^n^2)，比前一种方法略复杂。
//时间复杂度分析：每个位置都有两种情况，总共有 n^2 个位置
#include<bits/stdc++.h>
using namespace std;
const int N = 20;
int n;
char g[N][N];
int row[N],col[N],dg[N],udg[N];

void dfs(int x,int y,int s)         // s表示已经放上去的皇后个数
{
    if(y == n)  y = 0,x++;

    if(x == n){                     // x==n说明已枚举完n^2个位置
        if(s == n){                 // s==n说明成功放上去n个皇后
            for(int i = 0;i < n;++i){
                for(int j = 0;j < n;++j){
                    printf("%c",g[i][j]);
                }
                puts("");
            }
        }
        return;
    }

    // 分支1：放皇后
    if(!row[x] && !col[y] && !dg[y - x + n] && !udg[y + x]){
        g[x][y] = 'Q';
        row[x] = col[y] = dg[y-x+n] = udg[y+x] = true;
        dfs(x,y+1,s+1);
        row[x] = col[y] = dg[y-x+n] = udg[y+x] = false;
        g[x][y] = '.';
    }

    // 分支2：不放皇后
    dfs(x, y + 1, s);
}

int main()
{
    scanf("%d", &n);
    for(int i = 0;i < n;++i)
    {
        for(int j = 0;j < n;++j)
        {
            g[i][j] = '.';
        }
    }

    dfs(0,0,0);
    return 0;
}
```



## BFS

"有**最短路**"：搜到的点离当前越来越远(前提是权重一致)。

```cpp
//1.初识赋值队头
queue<int> q;
st[1] = true; // 表示1号点已经被遍历过
q.push(1);

//2.只要队不为空
while (q.size())
{
    int t = q.front();
    q.pop();
//3.扩展队头
    for (int i = h[t]; i != -1; i = ne[i])
    {
        int j = e[i];
        if (!s[j])
        {
            st[j] = true; // 表示点j已经被遍历过
            q.push(j);
        }
    }
}
```

### [844. 走迷宫 - AcWing题库](https://www.acwing.com/problem/content/846/)

给定一个 n×m 的二维整数数组，用来表示一个迷宫，数组中只包含 0 或 1，其中 0 表示可以走的路，1 表示不可通过的墙壁。

**输入样例**

```cpp
5 5
0 1 0 0 0
0 1 0 1 0
0 0 0 0 0
0 1 1 1 0
0 0 0 1 0
```

**输出样例**

```cpp
8
```

**解析**

![走迷宫](/img/acwing/chapter3/image-20220403215840059.png)

由于终点在第 8 层扩展到，故其路程即为 8 。

> 四点扩展：
>
> ![四点扩展](/img/acwing/chapter3/image-20220403221317576.png)
>

```cpp
//g存了图
//d表示每个点到起点的距离。
//可以用向量 dx 来表示四点扩展。
//d[x][y] = -1。第一次走过才算最短距离，否则就不算。
#include<bits/stdc++.h>
using namespace std;
const int N = 110;
int n,m,g[N][N],d[N][N];
typedef pair<int, int> PII;
PII q[N*N];	//手写队列

int bfs()
{
    int hh = 0,tt = 0;
    q[0] = {0,0};
    memset(d, -1, sizeof d);
    d[0][0] = 0;
    int dx[4] = {-1, 0, 1, 0}, dy[4] = {0, 1, 0, -1};		//四点扩展
    while(hh <= tt){
        auto t = q[hh++];
        for(int i = 0;i < 4;++i){
            int x = t.first + dx[i] ,y = t.second + dy[i];
            if(x >= 0 && x < n && y >= 0 && y < m && g[x][y] == 0 && d[x][y] == -1){
                d[x][y] = d[t.first][t.second] + 1;
                q[++tt] = {x,y};
            }
        }
    }
    return d[n-1][m-1];
}

int main()
{
    cin >> n >> m;
    for(int i = 0;i < n;++i){
        for(int j = 0;j < m;++j){
            cin >> g[i][j];
        }
    }
    cout << bfs() << endl;
    return 0;
}
```

如何输出路径？另开数组 pre[N] [N] 记录。

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N = 110;
int n,m,g[N][N],d[N][N];
typedef pair<int, int> PII;
PII q[N*N],pre[N][N];              			//路劲记录数组pre

int bfs()
{
    int hh = 0,tt = 0;
    q[0] = {0,0};
    memset(d, -1, sizeof d);
    d[0][0] = 0;
    int dx[4] = {-1, 0, 1, 0}, dy[4] = {0, 1, 0, -1};
    while(hh <= tt){
        auto t = q[hh++];
        for(int i = 0;i < 4;++i){
            int x = t.first + dx[i] ,y = t.second + dy[i];
            if(x >= 0 && x < n && y >= 0 && y < m && g[x][y] == 0 && d[x][y] == -1){
                d[x][y] = d[t.first][t.second] + 1;
                pre[x][y] = t;             //记录上一点
                q[++tt] = {x,y};
            }
        }
    }
    //倒着输出路劲
    int x = n-1,y = m-1;
    while(x||y){
        cout << x << ' '<< y << endl;
        auto t = pre[x][y];
        x = t.first,y = t.second;
    }

    return d[n-1][m-1];

}

int main()
{
    cin >> n >> m;
    for(int i = 0;i < n;++i){
        for(int j = 0;j < m;++j){
            cin >> g[i][j];
        }
    }
    cout << bfs() << endl;
    return 0;
}
```

### [845. 八数码 - AcWing题库](https://www.acwing.com/problem/content/847/)

交换过程如下：

```cpp
1 2 3   1 2 3   1 2 3   1 2 3
x 4 6   4 x 6   4 5 6   4 5 6
7 5 8   7 5 8   7 x 8   7 8 x
```

**输入样例**

```
2  3  4  1  5  x  7  6  8
```

**输出样例**

```
19
```

**解析**

基本思路：最小步数——**BFS** 。从起点到终点，步的权重为1，最少需要走多少步。

难点：

1. 状态表示	3*3格	(队列 ?)
2. 如何记录每个状态的距离  (dist ?)

```cpp
"1234X5678"
queue<string> q
unordered_map<string,int>dist
```

处理状态

1. 将字符串恢复3*3矩阵；
2. 移动；
3. 转化为字符串。

```cpp
#include<bits/stdc++.h>
using namespace std;

int bfs(string start)
{
    //目标状态
    string goal = "12345678x";
    //转移数组
    int dx[4] = {-1,0,1,0},dy[4] = {0,1,0,-1};
    //初始化队列和dist数组
    queue<string>q;
    unordered_map<string,int>dist;
    q.push(start);
    dist[start] = 0;

    while(q.size())
    {
        auto t = q.front(); q.pop();
        //记录当前状态的距离，如果是最终状态则返回距离
        int distance = dist[t];
        if(t == goal)   return distance;
        //查询x在字符串中的下标，然后转换为在矩阵中的坐标
        int k = t.find('x');
        int x = k/3,y = k%3;

        for(int i = 0;i < 4;++i)
        {
            //求转移后x的坐标
            int a = x + dx[i],b = y + dy[i];

            if(a >= 0 && a < 3 && b >= 0 && b < 3)
            {
                swap(t[k],t[a*3+b]);
                //当前状态是第一次遍历，记录距离，入队
                if(!dist.count(t))
                {
                    dist[t] = distance + 1;
                    q.push(t);
                }
                //还原状态，准备下一种转换情况
                swap(t[k],t[a*3+b]);
            }
        }
    }
    //无法转换到目标状态，返回-1
    return -1;

}

int main()
{
    string start;
    for(int i = 0;i < 9;++i)
    {
        char c;
        cin >> c;
        start += c;
    }
    cout << bfs(start) << endl;
    return 0;
}
```



## 树与图的深度优先遍历

1. 树与图的存储

   ![有向图的存储](/img/acwing/chapter3/image-20220406211821304.png)

   树是一种特殊的图，与图的存储方式相同。
   对于无向图中的边ab，存储两条有向边a->b, b->a。
   因此我们可以只考虑有向 **图的存储**。

   1. 邻接矩阵：g\[a][b] 存储边a->b   ；不适合稀疏

   2. 邻接表

   ```cpp
   // 对于每个点k，开一个单链表，存储k所有可以走到的点。
   //h[k]存储这个单链表的头结点；e[N]:当前节点对应图中编号。
   //即：e 存了节点值，ne 和 h 存了数组下标
   int h[N], e[N], ne[N], idx;		
   
   // 添加一条边a->b
   void add(int a, int b)
   {
   	e[idx] = b, ne[idx] = h[a], h[a] = idx ++ ;
   }
   ```


2. 树与图的遍历

   1. 深度优先遍历

      ![深度优先遍历](/img/acwing/chapter3/image-20220407213022270.png)
   
      ```cpp
      int dfs(int u)
      {
          st[u] = true; // st[u] 表示点u已经被遍历过
          for (int i = h[u]; i != -1; i = ne[i])
          {
              int j = e[i];
              if (!st[j]) dfs(j);
          }
      }
      ```

   2. 宽度优先遍历
   
       ![宽度优先遍历](/img/acwing/chapter3/image-20220407213058892.png)
       
       ```cpp
       queue<int> q;
       st[1] = true; // 表示1号点已经被遍历过	bool数组：哪些点已经被遍历过
       q.push(1);
       
       while (q.size())
       {
           int t = q.front();
           q.pop();
       
           for (int i = h[t]; i != -1; i = ne[i])
           {
               int j = e[i];
               if (!st[j])
               {
                   st[j] = true; // 表示点j已经被遍历过
                   q.push(j);
               }
           }
       }
       ```





### [846. 树的重心 - AcWing题库](https://www.acwing.com/problem/content/848/)

给定一颗树，树中包含 n 个结点（编号 1∼n）和 n−1 条无向边。请你找到树的重心，并输出将重心删除后，剩余各个连通块中点数的最大值。重心是指树中的一个结点，如果将这个点删除后，剩余各个连通块中点数的最大值最小，那么这个节点被称为树的重心。

**输入样例**

```cpp
9
1 2
1 7
1 4
2 8
2 5
4 3
3 9
4 6
```

**输出样例**

```cpp
4
```

**解析**

- 题意

  1. 删除1，三个连通块。最多者为4。

     ![-1连通块](/img/acwing/chapter3/image-20220407214122495.png)

  2. 删除2，三个连通块。最多者为6。

     ![-2连通块](/img/acwing/chapter3/image-20220407214250029.png)

     ……

- 分析

  求每一个子树点数大小，考虑深度优先遍历。

  下面的点数，递归，DFS过程中可以求出每个子树的点数。上面的点数，总数相减。

  如：删去4。每个子节点(集)为一部分，父节点及以上是另一部分。子节点的size可以返回得到，父可以总数相减。
  
  ![DFS](/img/acwing/chapter3/image-20220407214741679.png)
  
  树与图的遍历与边数和点数有关。时间复杂度BFS与DFS都是 **O(m+n)**。
  

```cpp
#include <bits/stdc++.h>
using namespace std;
const int N = 100010;
const int M = 2*N;      //以有向图的格式存储无向图，所以每个节点至多对应2n-2条边
int h[N];               //邻接表存储树
int e[M],ne[M];         //存储元素及列表next值
int idx;                //单链表指针
int n;                  //输入节点数
int ans = N;            //返回结果
bool st[N];             //是否已被访问

void add(int a,int b){
    e[idx] = b,ne[idx] = h[a],h[a] = idx++;
}

//以 u 为根的子树中点的数量
int dfs(int u){
    int res = 0;    //删掉某个节点之后，最大的连通块节点数
    st[u] = true;	//每个节点访问一次
    int sum = 1;	//当前那算一个点

    //访问u的每个子节点
    for(int i = h[u];i != -1;i = ne[i]){
        int j = e[i];       //每个节点的编号不同，用编号为下标标记是否被访问过
        if(!st[j]){
            int s = dfs(j);         // s 表当前子树的大小 
            res = max(res,s);       // 记录最大联通子图的节点数
            sum += s;             // 以j为根的树的节点数(以儿子为根节点的子树是以u为根节点的子树的一部分)
        }
    }
    res = max(res,n-sum);       //注意是 -sum
    ans = min(res,ans);
    return sum;
}

int main()
{
    cin >> n;
    memset(h, -1, sizeof h);
    for(int i = 0;i < n-1;++i){
        int a,b;
        cin >> a >> b;
        add(a, b);add(b,a);     //无向图
    }   

    dfs(1);						//任选一节点标号 <= n

    cout << ans << endl;

    return 0;
}
```

注：

- 此处并不是回溯，每个点搜到一次即可。故无需还原为 false
- 搜索是搜索图当中的节点编号，不是边。idx存的是边。



## 树与图的广度(宽度)优先遍历

### [847. 图中点的层次 - AcWing题库](https://www.acwing.com/problem/content/849/)

**输入格式**
第一行包含两个整数 n 和 m。

接下来 m 行，每行包含两个整数 a 和 b，表示存在一条从 a 走到 b 的长度为 1 的边。

**输出格式**
输出一个整数，表示 1 号点到 n 号点的最短距离。

**输入样例**

```cpp
4 5
1 2
2 3
3 4
1 3
1 4
```

**输出样例**

```cpp
1
```

**分析**

1. 点的权重都是1
2. 最短路

——BFS

宽搜求最短距离，**第一次**扩展到某个点，即为起点到它的最短距离/路径。(后面再遍历就不是了)

用宽搜框架搜索图，流程即是将图的结构结合到宽搜上。

宽搜框架搜索图：

![宽搜框架搜索图](/img/acwing/chapter3/image-20220427215621594.png)

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 100010;
int n,m;    				//点和边
int h[N],e[N],ne[N],idx;    //邻接表
int d[N],q[N];      		//距离 队列

void add(int a,int b)
{
    e[idx] = b,ne[idx] = h[a],h[a] = idx++;
}

int bfs()
{
    int hh = 0,tt = 0;
    q[0] = 1;
    memset(d,-1,sizeof d);
    
    d[1] = 0;              			//d[i] 节点 i 的距离。易错为d[0] = 0。
    
    while(hh <= tt)
    {
        int t = q[hh++];
        
        for(int i = h[t];i != -1;i = ne[i])
        {
            int j = e[i];
            if(d[j] == -1)          //没有被访问过
            {
                d[j] = d[t] + 1;
                q[++ tt] = j;       //数组模拟队列  扩展每个点的临边
            }
        }
    }
    
    return d[n];
}

int main()
{
    cin >> n >> m;
    
    memset(h,-1,sizeof h);
    
    for(int i = 0;i < m;++i)
    {
        int a,b;
        cin >> a >> b;
        add(a,b);
    }
    
    cout << bfs() << endl;
    
    return 0;
}
```



## 拓扑排序

有向无环图(拓扑图)一定有拓扑序列，图中任意一对顶点u和v，若边 (u,v)∈E (G)，u在线性序列中出现在v**之前**。

![所有边都是从前指向后](/img/acwing/chapter3/image-20220718212455089.png)

顶点 v 的**入度**是指以 v 为头的弧的数目；顶点v的**出度**(outdegree) 是指以 v 为尾的弧的数目。

拓扑系列的构建：

![构建拓扑系列](/img/acwing/chapter3/image-20220718225229891.png)

**模板**

```cpp
bool topsort()
{
    int hh = 0, tt = -1;

    // d[i] 存储点i的入度
    for (int i = 1; i <= n; i ++ )
        if (!d[i])
            q[ ++ tt] = i;

    while (hh <= tt)
    {
        int t = q[hh ++ ];

        for (int i = h[t]; i != -1; i = ne[i])
        {
            int j = e[i];
            if (-- d[j] == 0)
                q[ ++ tt] = j;
        }
    }

    // 如果所有点都入队了，说明存在拓扑序列；否则不存在拓扑序列。
    return tt == n - 1;
}
```

注意：拓扑序不唯一。

### [848. 有向图的拓扑序列 - AcWing题库](https://www.acwing.com/problem/content/850/)

**输入格式**

第一行包含两个整数 n 和 m。

接下来 m 行，每行包含两个整数 x 和 y，表示存在一条从点 x 到点 y 的有向边 (x,y)。

**输出格式**

共一行，如果存在拓扑序列，则输出任意一个合法的拓扑序列即可。

否则输出 −1。

**输入样例**

```cpp
3 3
1 2
2 3
1 3
```

**输出样例**

```cpp
1 2 3
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 100010;
int e[N],ne[N],h[N],idx;
int n,m;
int q[N],d[N];

void add(int a,int b)
{
    e[idx] = b,ne[idx] = h[a],h[a] = idx++;
}

bool toposort()
{
    int hh = 0,tt = -1;
    for(int i = 1;i <= n;++i)
    {
        if(!d[i])
            q[++tt] = i;			//将入度为零的 点 入队
    }
    while(hh <= tt)
    {
        int t = q[hh++];
        for(int i = h[t];i != -1;i = ne[i])
        {
            int j = e[i];
            d[j]--;					//删除点t指向点j的 边
            if(!d[j])   			//如果 点j 的入度为零了,就将点j入队
                q[++tt] = j;
        }
    }
    return tt == n-1;				//如果n个点都入队了话,那么该图为拓扑图,返回true
}

int main()
{
    cin >> n >> m;
    memset(h, -1, sizeof h);        //注意：记得初始化h
    for(int i = 0;i < m;++i)
    {
        int a,b;
        cin >> a >> b;
        add(a, b);
        d[b]++;
    }
    if(toposort())
    {
        for(int i = 0;i < n;++i)
        {
            printf("%d ",q[i]);		//队列中的点的次序就是拓扑序列
        }
    }
    else
    {
        printf("-1");
    }
    return 0;
}
```



## 最短路

**知识结构图**

n 点数，m 边数。

1. 单源最短路

   求从一个点到其他点的最短距离。

   1. 所有边权都是正数

      - 朴素的 Dijkstra 算法		（与边数无关，适合**稠密图**）

        O(n^2)

      - 堆优化版的 Dijkstra 算法  （**稀疏图**)

        O(mlogn)  —— 总共需要遍历 m 条边，插入数据修改小根堆的时间复杂度为 O(logn)

   2. 存在负权边

      - bellman-ford 算法  	

        O(nm)

      - spfa 算法   

        一般O(m)，最坏 O(nm) 

2. 多源汇最短路   

   - Floyd 算法     

     O(n^3)

   源点：起点

   汇点：终点

   其中一个点到另一个点的最短距离。

侧重于 **建图** ，如何定义点和边。

![最短路结构图](/img/acwing/chapter3/image-20220726235752051.png)



### Dijkstra

**模板**

1. 朴素dijkstra算法    (稠密图)

   **基本思路**：

   1. 初始化距离 dist[1] = 0,dist[i] = 正无穷

   2. s : 当前已经确定最短距离的点

      for(i : 0 ~ n)                                                                        n 次

      ​	t <----- 不在 s 中的，距离最近的点                              n 次

      ​	s <----- t

      ​	用 t 更新其他点的距离	dist[x] > dist[t] + w(权重) (如：从1号点走到x的路径长度是否大于1号点走到t加从t走到x，若满足，则更新)                   n 次

      每一次循环迭代都可以确定一个点的最短距离，循环 n 次确定 n 个点到起点的最短距离。总时间复杂度 O(n^2^) 。

   ```cpp
   int g[N][N];  // 存储每条边
   int dist[N];  // 存储1号点到每个点的最短距离
   bool st[N];   // 存储每个点的最短路是否已经确定
   
   // 求1号点到n号点的最短路，如果不存在则返回-1
   int dijkstra()
   {
       memset(dist, 0x3f, sizeof dist);
       dist[1] = 0;
   
       for (int i = 0; i < n - 1; i ++ )
       {
           int t = -1;		// 在还未确定最短路的点中，寻找距离最小的点
           for (int j = 1; j <= n; j ++ )
               if (!st[j] && (t == -1 || dist[t] > dist[j]))
                   t = j;
   
           // 用t更新其他点的距离
           for (int j = 1; j <= n; j ++ )
               dist[j] = min(dist[j], dist[t] + g[t][j]);
   
           st[t] = true;
       }
   
       if (dist[n] == 0x3f3f3f3f) return -1;
       return dist[n];
   }
   ```

2. 堆优化版dijkstra    (稀疏图)

   ![堆优化迪杰斯特拉](/img/acwing/chapter3/image-20220724210044521.png)
   
   ```cpp
   typedef pair<int, int> PII;
   
   int n;		// 点的数量
   int h[N], w[N], e[N], ne[N], idx;		// 邻接表存储所有边
   int dist[N];		// 存储所有点到1号点的距离
   bool st[N];		// 存储每个点的最短距离是否已确定
   
   // 求1号点到n号点的最短距离，如果不存在，则返回-1
   int dijkstra()
   {
       memset(dist, 0x3f, sizeof dist);
       dist[1] = 0;
       priority_queue<PII, vector<PII>, greater<PII>> heap;
       heap.push({0, 1});		// first存储距离，second存储节点编号
   
       while (heap.size())
       {
           auto t = heap.top();
           heap.pop();
   
           int ver = t.second, distance = t.first;
   
           if (st[ver]) continue;
           st[ver] = true;
   
           for (int i = h[ver]; i != -1; i = ne[i])
           {
               int j = e[i];
               if (dist[j] > distance + w[i])
               {
                   dist[j] = distance + w[i];
                   heap.push({dist[j], j});
               }
           }
       }
   
       if (dist[n] == 0x3f3f3f3f) return -1;
       return dist[n];
   }
   ```

#### [849. Dijkstra求最短路 I - AcWing题库](https://www.acwing.com/problem/content/851/)

**输入格式**

第一行包含整数 n 和 m。

接下来 m 行每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

**输出格式**

输出一个整数，表示 1 号点到 n 号点的最短距离。

如果路径不存在，则输出 −1。

**输入样例**

```cpp
3 3
1 2 2
2 3 1
1 3 4
```

**输出样例**

```cpp
3
```

**数据范围**

```cpp
1≤n≤500
1≤m≤105
```

**解析**

![n次迭代](/img/acwing/chapter3/image-20220721232815088.png)

**稠密图**，用邻接矩阵存；**稀疏图**，邻接表。

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N = 510;      //500点 100000边 稠密图 邻接矩阵

int n,m;
int g[N][N];    //邻接矩阵
int dist[N];    //当前的最短距离
bool st[N];     //每个点最短路是否已经确定

int Dijkstra()
{
    ////1.初始化
    memset(dist,0x3f,sizeof dist);          //0x3f代表无限大

    dist[1] = 0;                            //第一个点到自身的距离为0

    ////2.循环 n 次确定 n 个点到起点的最短距离
    for(int i = 1;i <= n;++i)               //n个点 n次迭代
    {
        int t = -1;                         //t存储当前访问的点
        for(int j = 1;j <= n;++j)           //找到最短距离的点
        {
            if(!st[j] && (t == -1 || dist[t] > dist[j]))	//在所有[未确定]的点中找到dist最小的点
                t = j;
        }
        //if(t == n)	break;				//可加上优化
        st[t] = true;                       //当前已经确定最短距离的点
        for(int j = 1;j <= n;++j)           //用 t 更新其他点的最短距离
        {
            dist[j] = min(dist[j],dist[t] + g[t][j]);
        }
    }
    if(dist[n] == 0x3f3f3f3f)   return -1;
    return dist[n];
}

int main()
{
    cin >> n >> m;
    memset(g,0x3f,sizeof g);
    while (m -- )
    {
        int x,y,z;
        cin >> x >> y >> z;
        g[x][y] = min(g[x][y],z);
    }
    cout << Dijkstra() << endl;
    return 0;
}
```



#### [850. Dijkstra求最短路 II - AcWing题库](https://www.acwing.com/problem/content/852/)

**输入格式**

第一行包含整数 n 和 m。

接下来 m 行每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

**输出格式**

输出一个整数，表示 1 号点到 n 号点的最短距离。

如果路径不存在，则输出 −1。

**输入样例**

```cpp
3 3
1 2 2
2 3 1
1 3 4
```

**输出样例**

```cpp
3
```

**数据范围**

```cpp
1≤ n,m ≤1.5×105
```

**解析**

注：迪杰斯特拉不能用于带负权边原因 [AcWing 853. 有边数限制的最短路 - AcWing](https://www.acwing.com/solution/content/6320/)

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 150010;
typedef pair<int, int> PII;     //<点的距离，点>
int h[N],e[N],ne[N],idx;        //稀疏图：邻接表
int w[N];                       //权重
int dist[N];
bool st[N];                      //点的最短路是否确定
int n,m;

void add(int x,int y,int z)
{ 
    // 有重边也不要紧，假设 1->2 有权重为 2 和 3 的边，再遍历到点 1 的时候 2 号点的距离会更新两次放入堆中
    // 堆中会有很多冗余的点，但是在弹出的时候还是会弹出最小值 2+x （x为之前确定的最短路径），
    // 并标记 st 为 true，所以下一次弹出 3+x 会 continue 不会向下执行。
    e[idx] = y,w[idx] = z,ne[idx] = h[x],h[x] = idx++;
}

int Diijkstra()
{
    memset(dist,0x3f,sizeof dist);
    dist[1] = 0;
    priority_queue<PII,vector<PII>,greater<PII>> heap;          //小根堆    根据距离排序
    heap.push({0,1});                                   
    while(heap.size())
    {
        auto t = heap.top();heap.pop();                         // 取不在集合S中距离最短的点
        int distance = t.first,ver = t.second;
        if(st[ver] == true) continue;
        st[ver] = true;
        for(int i = h[ver];i != -1;i = ne[i])
        {   
            int j = e[i];                                       // i只是个下标，e中在存的是i这个下标对应的点
            if(dist[j] > dist[ver] + w[i])
            {
                dist[j] = dist[ver] + w[i];
                heap.push({dist[j],j});
            }
        }
    }
    if(dist[n] == 0x3f3f3f3f)   return -1;
    return dist[n];
}

int main()
{
    cin >> n >> m;
    memset(h,-1,sizeof h);

    while(m--)
    {
        int x,y,z;
        cin >> x >> y >> z;
        add(x,y,z);
    }
    cout << Diijkstra() << endl;
    return 0;
}
```



### bellman-ford

**模板**

复杂度 O(nm)。

![贝尔曼算法](/img/acwing/chapter3/image-20220724233657691.png)

迭代 k 次 的含义：从1号点经过不超过 k 条边走到每个点的最短距离。(如果第 n 次迭代又更新了某些边，说明存在一条最短路径有 n 条边——意味有 n+1 个点，即一定有一个点一样，即路径存在环，而环又是更新过的，即**存在负环**)

有负权边**不一定**有最短路，可能负无穷，能求出最短路没有负权回路。

![负权回路](/img/acwing/chapter3/image-20220724233902063.png)

![负权回路不影响的情况](/img/acwing/chapter3/image-20220724235058794.png)

```cpp
int n, m;		// n表示点数，m表示边数
int dist[N];		// dist[x]存储1到x的最短路距离

struct Edge		// 边，a表示出点，b表示入点，w表示边的权重
{
    int a, b, w;
}edges[M];

// 求1到n的最短路距离，如果无法从1走到n，则返回-1。
int bellman_ford()
{
    memset(dist, 0x3f, sizeof dist);
    dist[1] = 0;

    // 如果第n次迭代仍然会松弛三角不等式，就说明存在一条长度是n+1的最短路径，由抽屉原理，路径中至少存在两个相同的点，说明图中存在负权回路。
    for (int i = 0; i < n; i ++ )
    {
        for (int j = 0; j < m; j ++ )
        {
            int a = edges[j].a, b = edges[j].b, w = edges[j].w;
            if (dist[b] > dist[a] + w)
                dist[b] = dist[a] + w;
        }
    }

    if (dist[n] == 0x3f3f3f3f) return -1;
    return dist[n];
}
```



#### [853. 有边数限制的最短路 - AcWing题库](https://www.acwing.com/problem/content/855/)

给定一个 n 个点 m 条边的有向图，图中可能存在重边和自环， **边权可能为负数**。(==不能迪杰斯特拉==)

请你求出从 1 号点到 n 号点的最**多经过 k 条边**(==负环不能无限转==)的最短距离，如果无法从 1 号点走到 n 号点，输出 impossible。

注意：图中可能 **存在负权回路**(==不一定存在最短路==) 

**输入格式**

第一行包含三个整数 n,m,k。

接下来 m 行，每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

点的编号为 1∼n。

**输出格式**

输出一个整数，表示从 1 号点到 n 号点的最多经过 k 条边的最短距离。

如果不存在满足条件的路径，则输出 impossible。

**数据范围**

```cpp
1≤n,k≤500,
1≤m≤10000,
1≤x,y≤n，
任意边长的绝对值不超过 10000。
```

**输入样例**

```cpp
3 3 1
1 2 1
2 3 1
1 3 3
```

**输出样例**

```cpp
3
```

**解析**

备份更新：防止出现串联影响结果。使用**备份更新**。

![备份跟新](/img/acwing/chapter3/image-20220725220206244.png)

负环不存在最短路。

![负环](/img/acwing/chapter3/image-20220725220834461.png)

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 510,M = 10010;
struct Edge{
    int a,b,c;
}edges[M];

int n,m,k;          //最多经过k条边
int dist[N];
int last[N];        //备份dist数组，避免更新时的串联干扰

void bellman_ford()
{
    memset(dist,0x3f,sizeof dist);
    dist[1] = 0;
    
    for(int i = 0;i < k;++i)
    {
        memcpy(last,dist,sizeof dist);
        for(int j = 0;j < m;++j)
        {
            auto e = edges[j];
            dist[e.b] = min(dist[e.b],last[e.a] + e.c);
        }
    }
}

int main()
{
    cin >> n >> m >> k;
    for(int i = 0;i < m;++i)
    {
        int a,b,c;
        cin >> a >> b >> c;
        edges[i] = {a,b,c};
    }
    
    bellman_ford();
    
    if(dist[n] > 0x3f3f3f3f / 2)    cout << "impossible";       //可能为正负无穷±权，故/2
    else    printf("%d\n",dist[n]);
    return 0;
}
```



### spfa

**模板**

针对 bellman-ford算法的更新边操作使用**队列**进行优化。

队列所存：待更新的点的集合。即队列里所存的是所有变小的节点(a)，只要一个节点变小了就将它放入队列，用以更新后面所有的后继。

一个点如果没有被更新过，他更新别人是没有效果的。

![队列优化](/img/acwing/chapter3/image-20220725233734211.png)

(加入前判断一下，若队列有 b 了就不再重复加入)

1. spfa 算法

   ```cpp
   int n;		// 总点数
   int h[N], w[N], e[N], ne[N], idx;		// 邻接表存储所有边
   int dist[N];		// 存储每个点到1号点的最短距离
   bool st[N];		// 存储每个点是否在队列中
   
   // 求1号点到n号点的最短路距离，如果从1号点无法走到n号点则返回-1
   int spfa()
   {
       memset(dist, 0x3f, sizeof dist);
       dist[1] = 0;
   
       queue<int> q;
       q.push(1);
       st[1] = true;
   
       while (q.size())
       {
           auto t = q.front();
           q.pop();
   
           st[t] = false;
   
           for (int i = h[t]; i != -1; i = ne[i])
           {
               int j = e[i];
               if (dist[j] > dist[t] + w[i])
               {
                   dist[j] = dist[t] + w[i];
                   if (!st[j])		// 如果队列中已存在j，则不需要将j重复插入
                   {
                       q.push(j);
                       st[j] = true;
                   }
               }
           }
       }
   
       if (dist[n] == 0x3f3f3f3f) return -1;
       return dist[n];
   }
   ```

2. spfa判断图中是否存在负环

   ![判断负环](/img/acwing/chapter3/image-20220726234040134.png)
   
   ```cpp
   int n;		// 总点数
   int h[N], w[N], e[N], ne[N], idx;		// 邻接表存储所有边
   int dist[N], cnt[N];		// dist[x]存储1号点到x的最短距离，cnt[x]存储1到x的最短路中经过的点数
   bool st[N];		// 存储每个点是否在队列中
   
   // 如果存在负环，则返回true，否则返回false。
   bool spfa()
   {
       // 不需要初始化dist数组
       // 原理：如果某条最短路径上有n个点（除了自己），那么加上自己之后一共有n+1个点，由抽屉原理一定有两个点相同，所以存在环。
   
       queue<int> q;
       for (int i = 1; i <= n; i ++ )
       {
           q.push(i);
           st[i] = true;
       }
   
       while (q.size())
       {
           auto t = q.front();
           q.pop();
   
           st[t] = false;
   
           for (int i = h[t]; i != -1; i = ne[i])
           {
               int j = e[i];
               if (dist[j] > dist[t] + w[i])
               {
                   dist[j] = dist[t] + w[i];
                   cnt[j] = cnt[t] + 1;
                   if (cnt[j] >= n) return true;		// 如果从1号点到x的最短路中包含至少n个点（不包括自己），则说明存在环
                   if (!st[j])
                   {
                       q.push(j);
                       st[j] = true;
                   }
               }
           }
       }
   
       return false;
   }
   ```
   
   

#### [851. spfa求最短路 - AcWing题库](https://www.acwing.com/problem/content/853/)

给定一个 n 个点 m 条边的有向图，图中可能存在重边和自环， 边权可能为负数。请你求出 1 号点到 n 号点的最短距离，如果无法从 1 号点走到 n 号点，则输出 impossible。数据保证不存在负权回路。

**输入格式**

第一行包含整数 n 和 m。

接下来 m 行每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

**输出格式**

输出一个整数，表示 1 号点到 n 号点的最短距离。

如果路径不存在，则输出 impossible。

**数据范围**

1≤n,m≤105，图中涉及边长绝对值均不超过 10000。

**输入样例**

```cpp
3 3
1 2 5
2 3 -3
1 3 4
```

**输出样例**

```cpp
2
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 100010;
int e[N],w[N],ne[N],h[N],idx;		//邻接表
int dist[N];						//每个点到源点距离
int st[N];							//是否在队列
int n,m;

void add(int a,int b,int c)
{
    e[idx] = b,w[idx] = c,ne[idx] = h[a],h[a] = idx++;
}

int spfa()
{
    memset(dist,0x3f,sizeof dist);
    dist[1] = 0;

    queue<int>q;
    q.push(1);
    st[1] = true;

    while(q.size())
    {
        int t = q.front();q.pop();
        st[t] = false;                          //从队列中取出来之后该节点st被标记为false,代表之后该节点如果发生更新可再次入队
        for(int i = h[t];i != -1;i = ne[i])
        {
            int j = e[i];
            if(dist[j] > dist[t] + w[i])
            {
                dist[j] = dist[t] + w[i];
                if(!st[j])                      //当前已经加入队列的结点，无需再次加入队列，即便发生了更新也只用更新数值即可，重复添加降低效率
                {   
                    q.push(j);
                    st[j] = true;
                }
            }
        }
    }
    return dist[n];
}

int main()
{
    cin >> n >> m;
    memset(h,-1,sizeof h);
    for(int i = 0;i < m;++i)
    {
        int a,b,c;
        cin >> a >> b >> c;
        add(a,b,c);
    }
    int res = spfa();
    if(res == 0x3f3f3f3f)   cout << "impossible";
    else    cout << res;
    return 0;
}
```



#### [852. spfa判断负环 - AcWing题库](https://www.acwing.com/problem/content/854/)

给定一个 n 个点 m 条边的有向图，图中可能存在重边和自环， 边权可能为负数。请你判断图中是否存在负权回路。

**输入格式**

第一行包含整数 n 和 m。

接下来 m 行每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

**输出格式**

如果图中存在负权回路，则输出 Yes，否则输出 No。

**数据范围**

1≤n≤2000,1≤m≤10000,图中涉及边长绝对值均不超过 10000。

**输入样例**

```cpp
3 3
1 2 -1
2 3 4
3 1 -4
```

**输出样例**

```cpp
Yes
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 2010,M = 10010;
int n,m;
int e[M],ne[M],w[M],h[M],idx;               //注：是 M 不是 N
int dist[N],cnt[N];
bool st[N];

void add(int a,int b,int c)
{
    e[idx] = b,w[idx] = c,ne[idx] = h[a],h[a] = idx++;
}

bool spfa()
{
    queue<int>q;

    //不能只放一号点进去。题目“是否存在负环”，不是“是否存在从1开始的负环”。可能存在一负环1号点到不了。应在开始将所有点都放入队列。
    for(int i = 1;i <= n;++i)
    {
        st[i] = true;
        q.push(i);
    }

    while(q.size())
    {
        int t = q.front();q.pop();
        st[t] = false;
        for(int i = h[t];i != -1; i = ne[i])
        {
            int j = e[i];
            if(dist[j] > dist[t] + w[i])
            {
                dist[j] = dist[t] + w[i];
                cnt[j] = cnt[t] + 1;
                if(cnt[j]  >= n)    return true;
                if(!st[j])
                {
                    q.push(j);
                    st[j] = true;
                }
            }
        }
    }
    return false;
}

int main()
{
    scanf("%d%d", &n, &m);

    memset(h, -1, sizeof h);

    for(int i = 0;i < m;++i)
    {
        int a,b,c;
        scanf("%d%d%d", &a, &b,&c);
        add(a, b, c);
    }
    if(spfa())  cout << "Yes";
    else    cout << "No";
    return 0;
}
```



### Floyd

**模板**

邻接矩阵存。

![Floyd](/img/acwing/chapter3/image-20220727205636248.png)

```cpp
//初始化
for (int i = 1; i <= n; i ++ )
    for (int j = 1; j <= n; j ++ )
        if (i == j) d[i][j] = 0;
else d[i][j] = INF;

// 算法结束后，d[a][b]表示a到b的最短距离
void floyd()
{
    for (int k = 1; k <= n; k ++ )
        for (int i = 1; i <= n; i ++ )
            for (int j = 1; j <= n; j ++ )
                d[i][j] = min(d[i][j], d[i][k] + d[k][j]);
}
```



#### [854. Floyd求最短路 - AcWing题库](https://www.acwing.com/problem/content/856/)

给定一个 n 个点 m 条边的有向图，图中可能存在重边和自环，边权可能为**负数**。再给定 k 个询问，每个询问包含两个整数 x 和 y，表示查询从点 x 到点 y 的最短距离，如果路径不存在，则输出 impossible。

数据保证图中不存在负权回路。(==否则最短距离负无穷==)

**输入格式**

第一行包含三个整数 n,m,k。

接下来 m 行，每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

接下来 k 行，每行包含两个整数 x,y，表示询问点 x 到点 y 的最短距离。

**输出格式**

共 k 行，每行输出一个整数，表示询问的结果，若询问两点间不存在路径，则输出 impossible。

**数据范围**

1≤n≤200,
1≤k≤n2
1≤m≤20000,
图中涉及边长绝对值均不超过 10000。

**输入样例**

```cpp
3 3 2
1 2 1
2 3 2
1 3 1
2 1
1 3
```

**输出样例**

```cpp
impossible
1
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;
int n,m,Q;
const int N = 210,INF = 1e9;
int dist[N][N];

void Floyd()
{
    //基于DP
    for(int k = 1;k <= n;++k)
    {
        for(int i = 1;i <= n;++i)
        {
            for(int j = 1;j <= n;++j)
            {
                dist[i][j] = min(dist[i][j],dist[i][k]+dist[k][j]);
            }
        }
    }
}

int main()
{
    cin >> n >> m >> Q;

    //初始化邻接矩阵
    for(int i = 1;i <= n;++i)
    {
        for(int j = 1;j <= n;++j)
        {
            if(i == j)  dist[i][j] = 0;
            else    dist[i][j] = INF;
        }
    }

    //赋值
    for(int i = 0;i < m;++i)
    {
        int a,b,c;
        cin >> a >> b >> c;
        dist[a][b] = min(dist[a][b],c);
    }

    Floyd();

    while(Q--)
    {
        int a,b;
        cin >> a >> b;
        if(dist[a][b] > INF/2)  cout << "impossible" << endl;
        else    cout << dist[a][b] << endl;
    }
    return 0;
}

```



## 最小生成树

动画讲解 [最小生成树(Kruskal(克鲁斯卡尔)和Prim(普里姆))算法动画演示_哔哩哔哩_bilibili](https://www.bilibili.com/video/BV1Eb41177d1/?vd_source=ee6f185bebb184a943308396273cbf85)

建图过程。描述算法思路与步骤。

**最小生成树**

最小生成树问题一般对应无向图

1. **Prim 算法**		O(n^2)

1. 1. 朴素版		(稠密图)
   2. 堆优化版	(稀疏图）	O(mlogn)	较少使用

2. **Kruskal 算法**		(稀疏图)		O(mlogm)

**二分图**

判别：染色法。DFS  (线性 O(n+m))

求：匈牙利算法	(最坏 O(mn)，一般远小于O(mn))

![结构](/img/acwing/chapter3/image-20220807232301879.png)

### Prim

1. 朴素 Prim

   s：当前已经在连通块中的所有点

   ![朴素 Prim](/img/acwing/chapter3/1659024402474-28d9c53c-daf4-4089-8724-ad249a5145c4.png)
   
2. 堆优化

**模板**


```cpp
int n;				// n表示点数
int g[N][N];		// 邻接矩阵，存储所有边
int dist[N];		// 存储其他点到当前最小生成树的距离
bool st[N];			// 存储每个点是否已经在生成树中
// 如果图不连通，则返回INF(值是0x3f3f3f3f), 否则返回最小生成树的树边权重之和
int prim()
{
    memset(dist, 0x3f, sizeof dist);

    int res = 0;
    for (int i = 0; i < n; i ++ )
    {
        int t = -1;
        for (int j = 1; j <= n; j ++ )
            if (!st[j] && (t == -1 || dist[t] > dist[j]))
                t = j;

        if (i && dist[t] == INF) return INF;

        if (i) res += dist[t];
        st[t] = true;

        for (int j = 1; j <= n; j ++ ) dist[j] = min(dist[j], g[t][j]);
    }

    return res;
}
```

#### [858. Prim算法求最小生成树 - AcWing题库](https://www.acwing.com/problem/content/860/)

给定一个 `n` 个点 `m` 条边的无向图，图中可能存在重边和自环，边权可能为负数。

求最小生成树的树边权重之和，如果最小生成树不存在则输出 `impossible`。

给定一张边带权的无向图 `G=(V,E)`，其中 `V` 表示图中点的集合，`E` 表示图中边的集合，`n=|V|，m=|E|`。

由 `V` 中的全部 `n` 个顶点和 `E` 中 `n−1` 条边构成的无向连通子图被称为 `G` 的一棵生成树，其中边的权值之和最小的生成树被称为无向图 `G` 的最小生成树。

**输入格式**

第一行包含两个整数 n 和 m。

接下来 m 行，每行包含三个整数 u,v,w，表示点 u 和点 v 之间存在一条权值为 w 的边。

**输出格式

共一行，若存在最小生成树，则输出一个整数，表示最小生成树的树边权重之和，如果最小生成树不存在则输出 impossible。

**数据范围**

`1≤n≤500,`
`1≤m≤105,`
图中涉及边的边权的绝对值均不超过 10000。

**输入样例**

```cpp
4 5
1 2 1
1 3 2
1 4 3
2 3 2
3 4 4
```

**输出样例**

```cpp
6
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 510,INF = 0x3f3f3f3f;
int n,m;
int g[N][N];
int dist[N];
bool st[N];

int prim()
{
    //初始化距离
    memset(dist,0x3f,sizeof dist);

    int res = 0;
    for(int i = 0;i < n;++i)
    {
        //找到集合外距离最近点
        int t = -1;
        for(int j = 1;j <= n;++j)
        {
            if(!st[j] && (t == -1 || dist[j] < dist[t]))
                t = j;
        }

        if(i && dist[t] == INF) return INF;

        if(i)   res += dist[t];                 //自环不能加入最小生成树中。若先更新在累加就不对了
        st[t] = true;       

        //用 t 更新其他点到 集合 的距离
        for(int j = 1;j <= n;++j)   dist[j] = min(dist[j],g[t][j]);     
    }
    return res;
}

int main()
{
    cin >> n >> m;
	//初始化邻接矩阵
    memset(g,0x3f,sizeof g);
	//赋值 无向图
    while (m -- )
    {
        int a,b,c;
        cin >> a >> b >> c;
        g[a][b] = g[b][a] = min(g[a][b],c);
    }

    int t = prim();
    
    if(t == INF)    cout << "impossible";
    else    cout << t;

    return 0;
}
```



### Kruskal

**模板**

![Kruskal](/img/acwing/chapter3/image-20220806003302335.png)

②结合了并查集的方法，类似 [837. 连通块中点的数量 - AcWing题库](https://www.acwing.com/problem/content/839/)

```cpp
int n, m;		// n是点数，m是边数
int p[N];		// 并查集的父节点数组
struct Edge		// 存储边
{
    int a, b, w;
    bool operator< (const Edge &W)const
    {
        return w < W.w;
    }
}edges[M];

int find(int x)		// 并查集核心操作
{
    if (p[x] != x) p[x] = find(p[x]);
    return p[x];
}

int kruskal()
{
    sort(edges, edges + m);

    for (int i = 1; i <= n; i ++ ) p[i] = i;    // 初始化并查集

    int res = 0, cnt = 0;
    for (int i = 0; i < m; i ++ )
    {
        int a = edges[i].a, b = edges[i].b, w = edges[i].w;

        a = find(a), b = find(b);
        if (a != b)		// 如果两个连通块不连通，则将这两个连通块合并
        {
            p[a] = b;
            res += w;
            cnt ++ ;
        }
    }

    if (cnt < n - 1) return INF;
    return res;
}
```

#### [859. Kruskal算法求最小生成树 - AcWing题库](https://www.acwing.com/problem/content/861/)

给定一个 n 个点 m 条边的无向图，图中可能存在重边和自环，边权可能为负数。求最小生成树的树边权重之和，如果最小生成树不存在则输出 impossible。

给定一张边带权的无向图 G=(V,E)，其中 V 表示图中点的集合，E 表示图中边的集合，n=|V|，m=|E|。

由 V 中的全部 n 个顶点和 E 中 n−1 条边构成的无向连通子图被称为 G 的一棵生成树，其中边的权值之和最小的生成树被称为无向图 G 的最小生成树。

**输入格式**

第一行包含两个整数 n 和 m。

接下来 m 行，每行包含三个整数 u,v,w，表示点 u 和点 v 之间存在一条权值为 w 的边。

**输出格式**

共一行，若存在最小生成树，则输出一个整数，表示最小生成树的树边权重之和，如果最小生成树不存在则输出 impossible。

**数据范围**

1≤n≤105,
1≤m≤2∗105,
图中涉及边的边权的绝对值均不超过 1000。

**输入样例**

```cpp
4 5
1 2 1
1 3 2
1 4 3
2 3 2
3 4 4
```

**输出样例**

```cpp
6
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;
const int N = 100010,M = 200010;
int n,m;
int p[N],cnt[N];

struct Edges
{
    int a,b,w;

    bool operator< (const Edges& e) const
    {
        return w < e.w;
    }
}edges[M];

int find(int x)                             //并查集模板
{
    if(p[x] != x)   p[x] = find(p[x]);              //注：是p[x]
    return p[x];
}

int Kruskal()
{
    sort(edges,edges+m);

    int res = 0,cnt = 0;                    //res记录最小生成树的树边权重之和,cnt记录全部加入到树的集合中边的数量
    for(int i = 1;i <= n;++i)   p[i] = i;

    for(int i = 0;i < m;++i)
    {
        int a = edges[i].a,b = edges[i].b,w = edges[i].w;

        a = find(a),b = find(b);
        /*
        具体可以参考连通块中点的数量,如果a和b已经在一个集合当中了,说明这两个点已经被一种方式连接起来了,
        如果加入a-b这条边,会导致集合中有环的生成,而树中不允许有环生成,所以一个连通块中的点的数量假设
        为x,那么里面x个节点应该是被串联起来的,有x-1条边,所以只有当a,b所属的集合不同时,才能将a-b这条
        边加入到总集合当中去
        */
        if(a != b)
        {
            p[a] = b;               //集合连接
            res += w;               //权重相加
            cnt ++;                 //边数加1
        }
    }
    if(cnt < n-1)   return 0x3f3f3f3f;
    return res;
}

int main()
{
    scanf("%d%d", &n, &m);
    for(int i = 0;i < m;++i)
    {
        int a,b,w;
        scanf("%d%d%d", &a, &b,&w);
        edges[i] = {a,b,w};
    }

    int t = Kruskal();

    if(t == 0x3f3f3f3f) cout << "impossible";
    else    printf("%d\n", t);

    return 0;
}
```



## 染色法判定二分图

无向图G为二分图的**充分必要条件**是，G至少有两个顶点，且其所有回路的长度均为偶数。

![二分图](/img/acwing/chapter3/format,f_auto.png)

![非二分图](/img/acwing/chapter3/format,f_auto-16598814245022.png)

![反证法：图中存在奇数环不是二分图](/img/acwing/chapter3/image-20220807220126032.png)

由于**图中不含奇数环，所以染色过程中一定是没有矛盾的**。即：如果一个图用染色法没有矛盾发生，那么他是一个二分图；如果染色过程出现矛盾，则不是二分图。

![染色法](/img/acwing/chapter3/image-20220807221952435.png)

**模板**

```cpp
int n;		// n表示点数
int h[N], e[M], ne[M], idx;		// 邻接表存储图
int color[N];		// 表示每个点的颜色，-1表示为染色，0表示白色，1表示黑色
// 参数：u表示当前节点，father表示当前节点的父节点（防止向树根遍历），c表示当前点的颜色
bool dfs(int u, int father, int c)
{
    color[u] = c;
    for (int i = h[u]; i != -1; i = ne[i])
    {
        int j = e[i];
        if (color[j] == -1)
        {
            if (!dfs(j, u, !c)) return false;
        }
        else if (color[j] == c) return false;
    }

    return true;
}

bool check()
{
    memset(color, -1, sizeof color);
    bool flag = true;
    for (int i = 1; i <= n; i ++ )
        if (color[i] == -1)
            if (!dfs(i, -1, 0))
            {
                flag = false;
                break;
            }
    return flag;
}
```

### [860. 染色法判定二分图 - AcWing题库](https://www.acwing.com/problem/content/862/)

给定一个 n 个点 m 条边的无向图，图中可能存在重边和自环。

请你判断这个图是否是二分图。

**输入格式**

第一行包含两个整数 n 和 m。

接下来 m 行，每行包含两个整数 u 和 v，表示点 u 和点 v 之间存在一条边。

**输出格式**

如果给定图是二分图，则输出 Yes，否则输出 No。

**数据范围**

1≤n,m≤105

**输入样例**

```cpp
4 4
1 3
1 4
2 3
2 4
```

**输出样例**

```cpp
Yes
```

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 100010,M = 200010;      // 由于是无向图, 顶点数最大是N，那么边数M最大是顶点数的2倍  
int n,m;
int e[M],ne[M],h[N],idx;              //注：e 和 ne 是 M
int st[N];

void add(int a,int b)
{
    e[idx] = b,ne[idx] = h[a],h[a] = idx++;      //邻接表模板
}

bool dfs(int u,int color)
{
    st[u] = color;
    for(int i = h[u];i != -1;i = ne[i])                     
    {
        int j = e[i];
        if(!st[j])
        {
            if(!dfs(j,3 - color))   return false;   //染色可以使用1和2区分不同颜色，用0表示未染色。3 - color表示染色从1 ~ 2
        }
        else
        {
            if(st[j] == color)   return false;      //只有某个点染色失败才能立刻break/return。染色失败相当于存在相邻的2个点染了相同的颜色
        }
    }
    return true;
}

int main()
{
    cin >> n >> m;

    memset(h,-1,sizeof h);              //注：初始化

    while(m--)
    {
        int a,b;
        scanf("%d%d", &a, &b);
        add(a,b),add(b,a);
    }

    bool flag = true;
    for(int i = 1;i <= n;++i)      //遍历所有点，每次将未染色的点进行dfs, (初始)默认染成 1 或者 2
    {
        if(!st[i])
        {
            if(!dfs(i,1))
            {
                flag = false;
                break;
            }
        }
    }

    if(flag)    cout << "Yes";
    else    cout << "No";
    return 0;
}

```

扩展： [257. 关押罪犯 - AcWing题库](https://www.acwing.com/problem/content/259/)



## 匈牙利算法

在**二分图**中最多能找到多少条**没有公共端点**的边。

**模板**

```cpp
int n;		// n表示点数
int h[N], e[M], ne[M], idx;		// 邻接表存储所有边
int match[N];		// 存储每个点当前匹配的点
bool st[N];		// 表示每个点是否已经被遍历过,防止重复搜索一个点

bool find(int x)
{
    for (int i = h[x]; i != -1; i = ne[i])
    {
        int j = e[i];
        if (!st[j])
        {
            st[j] = true;
            if (match[j] == 0 || find(match[j]))
            {
                match[j] = x;
                return true;
            }
        }
    }

    return false;
}

// 求最大匹配数
int res = 0;
for (int i = 1; i <= n; i ++ )
{
    memset(st, false, sizeof st);
    if (find(i)) res ++ ;
}
```

### [861. 二分图的最大匹配 - AcWing题库](https://www.acwing.com/problem/content/863/)

给定一个二分图，其中左半部包含 n1 个点（编号 1∼n1），右半部包含 n2 个点（编号 1∼n2），二分图共包含 m 条边。

数据保证任意一条边的两个端点都不可能在同一部分中。

请你求出二分图的最大匹配数。

> 二分图的匹配：给定一个二分图 G，在 G 的一个子图 M 中，M 的边集 {E} 中的任意两条边都不依附于同一个顶点，则称 M 是一个匹配。
>
> 二分图的最大匹配：所有匹配中包含边数最多的一组匹配被称为二分图的最大匹配，其边数即为最大匹配数。

**输入格式**

第一行包含三个整数 n1、 n2 和 m。

接下来 m 行，每行包含两个整数 u 和 v，表示左半部点集中的点 u 和右半部点集中的点 v 之间存在一条边。

**输出格式**

输出一个整数，表示二分图的最大匹配数。

**数据范围**

1≤n1,n2≤500,
1≤u≤n1,
1≤v≤n2,
1≤m≤$10^5$

**解析**

```cpp
#include<bits/stdc++.h>
using namespace std;

const int N = 100010,M = 200010;
int e[M],ne[M],h[N],idx;                // 邻接表    
int match[N];                           // 存储(R)每个点当前匹配的(L)点
bool st[N];                             // 表示(R)每个点是否已经被遍历过,防止重复搜索一个点

void add(int a,int b)
{
    e[idx] = b,ne[idx] = h[a],h[a] = idx++;
}

bool find(int x)
{
    for(int i = h[x];i != -1;i = ne[i])
    {
        int j = e[i];
        if(!st[j])
        {
            st[j] = true;
            if(match[j] == 0 || find(match[j]))    
            //此处递归的解析：(当前L统一表示L1，R的对象统一L2表示。match[]表示该R的对象是谁，st[]该R是否被该L匹配过)
            //①L2只指了一个R，L1就只能找下一个R。即此for循环
            //②
            //1. L2有另一个R2（能和R2匹配），L1就给L2说：“换一个”，然后该L1就和该R在一起
            //2. L2就去重新找对象，此时L1的st[]是传给L2当参数用了，
            //但不会对L2重新找对象有影响，因为L1遍历过的R肯定都有对象了，L2也就不用再去尝试；
            //而L1没匹配过的，L2就可以从中选择自己的匹配项挨个匹配
            {
                match[j] = x;
                return true;
            }
        }
    }
    return false;
}

int main()
{
    int n1,n2,m;
    cin >> n1 >> n2 >> m;
    memset(h, -1, sizeof h);
    while (m -- )
    {
        int a,b;
        cin >> a >> b;
        add(a, b);		//虽然是无向边，但寻找过程只早左边每个点所指向的所有边，不会找右边点的所有边。故存储时只存左边指向右边即可
    }
    
    // 求最大匹配数
    int res = 0;			//res 存的是匹配数量
    for(int i = 1;i <= n1;++i)
    {
        memset(st,false,sizeof st);
        if(find(i)) res++;
    }
    cout << res;
    
    return 0;
}
```

扩展：[372. 棋盘覆盖 - AcWing题库](https://www.acwing.com/problem/content/374/)



chapter 3 END。	
