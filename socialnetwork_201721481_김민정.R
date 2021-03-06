read.csv("featuring.csv")
featuring <- read.csv("featuring.csv")    #featuring변수에 데이터넣기
head(featuring)
class(featuring)  #형식확인

library(igraph)
library(tidygraph)
library(ggraph)

ft <- as_tbl_graph(featuring)  #그래프로 바꾸기
class(ft)

plot(ft)    #그림그리기

featuring %>%
  as_tbl_graph() %>%
  ggraph(layout='lgl') + 
  geom_node_text(aes(label=name)) +            #노드자리 글씨쓰기
  geom_edge_link(aes(start_cap = label_rect(node1.name), end_cap = label_rect(node2.name)))

library(dplyr)
featuring %>%                                       #중심성 계산하기 내림차순 정렬
  as_tbl_graph() %>% 
  mutate(bet= centrality_betweenness()) %>%
  as_tibble %>%
  arrange(desc(bet))

featuring %>%                            #중심성 여러개 동시계산하기
  as_tbl_graph() %>% 
  mutate(bet=centrality_betweenness(),
         clo=centrality_closeness()) %>%
  as_tibble

featuring %>% as_tbl_graph() %>%                   #거리 계산하기 
  with_graph(graph_mean_dist())
#해당 네트워크는 0.2단계만 거치면 아는사이 (나는 1임)










subway <- read.csv('subway.csv')

subway %>% as_tbl_graph() %>%         
  ggraph(layout='lgl') + 
  geom_edge_link(aes(color=line)) +               #네트워트는 호선별로 다르게 색깔지정
  geom_node_point(color='gray30', size=1)           #노드 크기는1, 색깔은 30% 회색












metro <- read.csv('metro.csv')
head(metro)

metro %>% as_tbl_graph() %>%  #중심성구하기
  mutate(eig=centrality_eigen()) %>%
  as_tibble %>% 
  arrange(desc(eig))
metro %>% as_tbl_graph() %>% # 더 사람이 많이 다니는 역에 이동하는 인원을 가중치두기
  mutate(eig=centrality_pagerank(weights=total)) %>% 
  as_tibble











ko <- read.csv('kovo.csv')
head(ko) 
ko_고교 <- ko[, c(1, 2)]      #데이터 처리: 선수, 고교 
ko_대학 <- ko[, c(1, 3)]      #데이터 처리: 선수, 대학
names(ko_고교)[2] <- '학교'
names(ko_대학)[2] <- '학교'
ko <- rbind(ko_고교, ko_대학)

ko %>% as_tbl_graph() %>%           #중심성 계산
  mutate(eig=centrality_eigen()) %>%
  arrange(desc(eig)) %>%
  as_tibble

ko %>% as_tbl_graph() %>%          #다른 노드도 중심성이 올라가는 것을 방지하기 위해서 페이지 랭크함
  mutate(pr=centrality_pagerank()) %>%
  arrange(desc(pr)) %>%
  as_tibble

kog <- graph_from_data_frame(ko)     #노드에서 선수만 분리 
V(kog)$type <- bipartite_mapping(kog)$type
kom <- as_incidence_matrix(kog)
kom <- kom %*% t(kom)
diag(kom) <- 0
kom %>% as_tbl_graph()            #고교또는 대학만 같은 사이는 1이고, 고교와 대학 모두 같을땐 2로 가중치 표시됨 

kom %>% as_tbl_graph() %>%                    #비슷한 노드끼리 그룹화시키기
  mutate(cm=group_infomap()) %>%
  arrange(desc(cm)) %>%
  as_tibble

kom %>% as_tbl_graph() %>%
  mutate(pg=centrality_pagerank(),
         cm=group_infomap()) %>%
  ggraph(layout='fr') + 
  geom_edge_link(aes(width=weight), alpha=.8) +         #네트워크 두께 0.2에서2사이 투명도 80%
  scale_edge_width(range=c(0.2, 2)) +                 
  geom_node_point(aes(size=pg, color=as.factor(cm)))    #노드 그라데이션

kom%>% as_tbl_graph() %>%                   #그래프거리 계산하기 
  with_graph(graph_mean_dist())             #거리가2.5나옴 나(1)을 제외한 1.5단계만 거치면 아는사이 
