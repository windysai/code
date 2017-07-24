#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <algorithm>
#include <iostream>
#include <ctype.h>
#include <map>
using namespace std;

map<int, int> my_map;
const int maxn = 26 + 2;
const int N = 1000 + 2;
const int len = 26;
char s1[maxn], s2[maxn];
char s3[N];

int main(){
    #ifndef ONLINE_JUDGE
       freopen("in.txt", "r", stdin);
    #endif // ONLINE_JUDGE

    while(scanf("%s%s%s", s1, s2, s3) != EOF) {
       my_map.clear();

       for (int i = 0; i < len; i++) {
           my_map[s1[i]-'a'] = i;
       }

       int len_s3 = strlen(s3);
       for (int i = 0; i < len_s3; i++) {
            if (isupper(s3[i])) {
                char up = char(s2[my_map[s3[i]-'A']]);
                cout << char(up-'a'+'A');

            }
            else if (islower(s3[i])){
                cout << char(s2[my_map[s3[i]-'a']]);
            }
            else
                cout << s3[i];
       }
       puts("");
    }
    return 0;
}


