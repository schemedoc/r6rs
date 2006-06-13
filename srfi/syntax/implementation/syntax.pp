;;; syntax.pp
;;; automatically generated from syntax.ss
;;; Wed May 31 00:51:18 2006
;;; see copyright notice in syntax.ss

((lambda ()
   (letrec* ([eval-hook0 (lambda (x1263) (eval x1263))]
             [error-hook1 (lambda (who1262 why1261 what1260)
                            (error who1262 '"~a ~s" why1261 what1260))]
             [gensym-hook2 gensym]
             [no-source3 '#f]
             [annotation?4 (lambda (x1259) '#f)]
             [annotation-expression5 (lambda (x1258) x1258)]
             [annotation-source6 (lambda (x1257) no-source3)]
             [strip-annotation7 (lambda (x1256) x1256)]
             [globals8 '()]
             [global-extend9 (lambda (type1255 sym1254 value1253)
                               (set! globals8
                                 (cons
                                   (cons
                                     sym1254
                                     (make-binding110 type1255 value1253))
                                   globals8)))]
             [global-lookup10 (lambda (sym1251)
                                ((lambda (t1252)
                                   (if t1252
                                       (cdr t1252)
                                       (cons 'global sym1251)))
                                  (assq sym1251 globals8)))]
             [build-application11 (lambda (src1250 proc-expr1249
                                           arg-expr*1248)
                                    (cons proc-expr1249 arg-expr*1248))]
             [build-global-reference25 (lambda (src1247 var1246)
                                         var1246)]
             [build-lexical-reference26 (lambda (src1245 var1244)
                                          var1244)]
             [build-lexical-assignment27 (lambda (src1243 var1242
                                                  expr1241)
                                           (cons
                                             'set!
                                             (cons
                                               var1242
                                               (cons expr1241 '()))))]
             [build-global-assignment28 (lambda (src1240 var1239
                                                 expr1238)
                                          (cons
                                            'set!
                                            (cons
                                              var1239
                                              (cons expr1238 '()))))]
             [build-lambda29 (lambda (src1234 var*1233 rest?1232
                                      expr1231)
                               (cons
                                 'lambda
                                 (cons
                                   (if rest?1232
                                       ((letrec ([f1235 (lambda (var1237
                                                                 var*1236)
                                                          (if (pair?
                                                                var*1236)
                                                              (cons
                                                                var1237
                                                                (f1235
                                                                  (car var*1236)
                                                                  (cdr var*1236)))
                                                              var1237))])
                                          f1235)
                                         (car var*1233)
                                         (cdr var*1233))
                                       var*1233)
                                   (cons expr1231 '()))))]
             [build-primref30 (lambda (src1230 name1229) name1229)]
             [build-data31 (lambda (src1228 datum1227)
                             (cons 'quote (cons datum1227 '())))]
             [build-sequence32 (lambda (src1224 expr*1223)
                                 ((letrec ([loop1225 (lambda (expr*1226)
                                                       (if (null?
                                                             (cdr expr*1226))
                                                           (car expr*1226)
                                                           (cons
                                                             'begin
                                                             (append
                                                               expr*1226
                                                               '()))))])
                                    loop1225)
                                   expr*1223))]
             [build-letrec33 (lambda (src1222 var*1221 rhs-expr*1220
                                      body-expr1219)
                               (if (null? var*1221)
                                   body-expr1219
                                   (cons
                                     'letrec
                                     (cons
                                       (map list var*1221 rhs-expr*1220)
                                       (cons body-expr1219 '())))))]
             [build-letrec*34 (lambda (src1218 var*1217 rhs-expr*1216
                                       body-expr1215)
                                (if (null? var*1217)
                                    body-expr1215
                                    (cons
                                      'letrec*
                                      (cons
                                        (map list var*1217 rhs-expr*1216)
                                        (cons body-expr1215 '())))))]
             [build-lexical-var35 (lambda (src1214 id1213) (gensym))]
             [self-evaluating?36 (lambda (x1209)
                                   ((lambda (t1210)
                                      (if t1210
                                          t1210
                                          ((lambda (t1211)
                                             (if t1211
                                                 t1211
                                                 ((lambda (t1212)
                                                    (if t1212
                                                        t1212
                                                        (char? x1209)))
                                                   (string? x1209))))
                                            (number? x1209))))
                                     (boolean? x1209)))]
             [andmap37 (lambda (f1203 ls1202 . more1201)
                         ((letrec ([andmap1204 (lambda (ls1207 more1206
                                                        a1205)
                                                 (if (null? ls1207)
                                                     a1205
                                                     ((lambda (a1208)
                                                        (if a1208
                                                            (andmap1204
                                                              (cdr ls1207)
                                                              (map cdr
                                                                   more1206)
                                                              a1208)
                                                            '#f))
                                                       (apply
                                                         f1203
                                                         (car ls1207)
                                                         (map car
                                                              more1206)))))])
                            andmap1204)
                           ls1202
                           more1201
                           '#t))]
             [make-syntax-object77 (lambda (expression1200 mark*1199
                                            subst*1198)
                                     (vector
                                       'syntax-object
                                       expression1200
                                       mark*1199
                                       subst*1198))]
             [syntax-object?78 (lambda (x1197)
                                 (if (vector? x1197)
                                     (if (= (vector-length x1197) '4)
                                         (eq? (vector-ref x1197 '0)
                                              'syntax-object)
                                         '#f)
                                     '#f))]
             [syntax-object-expression79 (lambda (x1196)
                                           (vector-ref x1196 '1))]
             [syntax-object-mark*80 (lambda (x1195)
                                      (vector-ref x1195 '2))]
             [syntax-object-subst*81 (lambda (x1194)
                                       (vector-ref x1194 '3))]
             [set-syntax-object-expression!82 (lambda (x1193 update1192)
                                                (vector-set!
                                                  x1193
                                                  '1
                                                  update1192))]
             [set-syntax-object-mark*!83 (lambda (x1191 update1190)
                                           (vector-set!
                                             x1191
                                             '2
                                             update1190))]
             [set-syntax-object-subst*!84 (lambda (x1189 update1188)
                                            (vector-set!
                                              x1189
                                              '3
                                              update1188))]
             [strip85 (lambda (x1181 m*1180)
                        (if (top-marked?89 m*1180)
                            (strip-annotation7 x1181)
                            ((letrec ([f1182 (lambda (x1183)
                                               (if (syntax-object?78 x1183)
                                                   (strip85
                                                     (syntax-object-expression79
                                                       x1183)
                                                     (syntax-object-mark*80
                                                       x1183))
                                                   (if (pair? x1183)
                                                       ((lambda (a1185
                                                                 d1184)
                                                          (if (if (eq? a1185
                                                                       (car x1183))
                                                                  (eq? d1184
                                                                       (cdr x1183))
                                                                  '#f)
                                                              x1183
                                                              (cons
                                                                a1185
                                                                d1184)))
                                                         (f1182
                                                           (car x1183))
                                                         (f1182
                                                           (cdr x1183)))
                                                       (if (vector? x1183)
                                                           ((lambda (old1186)
                                                              ((lambda (new1187)
                                                                 (if (andmap37
                                                                       eq?
                                                                       old1186
                                                                       new1187)
                                                                     x1183
                                                                     (list->vector
                                                                       new1187)))
                                                                (map f1182
                                                                     old1186)))
                                                             (vector->list
                                                               x1183))
                                                           x1183))))])
                               f1182)
                              x1181)))]
             [source86 (lambda (e1179)
                         (if (syntax-object?78 e1179)
                             (source86 (syntax-object-expression79 e1179))
                             (if (annotation?4 e1179)
                                 (annotation-source6 e1179)
                                 no-source3)))]
             [unannotate87 (lambda (x1178)
                             (if (annotation?4 x1178)
                                 (annotation-expression5 x1178)
                                 x1178))]
             [top-mark*88 '(top)]
             [top-marked?89 (lambda (m*1177)
                              (memq (car top-mark*88) m*1177))]
             [gen-mark90 (lambda () (string '#\m))]
             [anti-mark91 '#f]
             [add-mark92 (lambda (m1176 e1175)
                           (syntax-object97 e1175 (list m1176) '(shift)))]
             [same-marks?93 (lambda (x1173 y1172)
                              ((lambda (t1174)
                                 (if t1174
                                     t1174
                                     (if (if (not (null? x1173))
                                             (not (null? y1172))
                                             '#f)
                                         (if (eq? (car x1173) (car y1172))
                                             (same-marks?93
                                               (cdr x1173)
                                               (cdr y1172))
                                             '#f)
                                         '#f)))
                                (eq? x1173 y1172)))]
             [top-subst*94 '()]
             [add-subst95 (lambda (subst1171 e1170)
                            (if subst1171
                                (syntax-object97
                                  e1170
                                  '()
                                  (list subst1171))
                                e1170))]
             [join-wraps96 (lambda (m1*1161 s1*1160 e1159)
                             (letrec* ([cancel1162 (lambda (ls11166
                                                            ls21165)
                                                     ((letrec ([f1167 (lambda (x1169
                                                                               ls11168)
                                                                        (if (null?
                                                                              ls11168)
                                                                            (cdr ls21165)
                                                                            (cons
                                                                              x1169
                                                                              (f1167
                                                                                (car ls11168)
                                                                                (cdr ls11168)))))])
                                                        f1167)
                                                       (car ls11166)
                                                       (cdr ls11166)))])
                               ((lambda (m2*1164 s2*1163)
                                  (if (if (not (null? m1*1161))
                                          (if (not (null? m2*1164))
                                              (eq? (car m2*1164)
                                                   anti-mark91)
                                              '#f)
                                          '#f)
                                      (values
                                        (cancel1162 m1*1161 m2*1164)
                                        (cancel1162 s1*1160 s2*1163))
                                      (values
                                        (append m1*1161 m2*1164)
                                        (append s1*1160 s2*1163))))
                                 (syntax-object-mark*80 e1159)
                                 (syntax-object-subst*81 e1159))))]
             [syntax-object97 (lambda (e1156 m*1155 s*1154)
                                (if (syntax-object?78 e1156)
                                    (call-with-values
                                      (lambda ()
                                        (join-wraps96 m*1155 s*1154 e1156))
                                      (lambda (m*1158 s*1157)
                                        (make-syntax-object77
                                          (syntax-object-expression79
                                            e1156)
                                          m*1158
                                          s*1157)))
                                    (make-syntax-object77
                                      e1156
                                      m*1155
                                      s*1154)))]
             [make-rib98 (lambda (sym*1153 mark**1152 label*1151)
                           (vector 'rib sym*1153 mark**1152 label*1151))]
             [rib?99 (lambda (x1150)
                       (if (vector? x1150)
                           (if (= (vector-length x1150) '4)
                               (eq? (vector-ref x1150 '0) 'rib)
                               '#f)
                           '#f))]
             [rib-sym*100 (lambda (x1149) (vector-ref x1149 '1))]
             [rib-mark**101 (lambda (x1148) (vector-ref x1148 '2))]
             [rib-label*102 (lambda (x1147) (vector-ref x1147 '3))]
             [set-rib-sym*!103 (lambda (x1146 update1145)
                                 (vector-set! x1146 '1 update1145))]
             [set-rib-mark**!104 (lambda (x1144 update1143)
                                   (vector-set! x1144 '2 update1143))]
             [set-rib-label*!105 (lambda (x1142 update1141)
                                   (vector-set! x1142 '3 update1141))]
             [make-empty-rib106 (lambda () (make-rib98 '() '() '()))]
             [extend-rib!107 (lambda (rib1140 id1139 label1138)
                               (begin
                                 (set-rib-sym*!103
                                   rib1140
                                   (cons
                                     (id->sym120 id1139)
                                     (rib-sym*100 rib1140)))
                                 (set-rib-mark**!104
                                   rib1140
                                   (cons
                                     (syntax-object-mark*80 id1139)
                                     (rib-mark**101 rib1140)))
                                 (set-rib-label*!105
                                   rib1140
                                   (cons
                                     label1138
                                     (rib-label*102 rib1140)))))]
             [make-full-rib108 (lambda (id*1131 label*1130)
                                 (if (not (null? id*1131))
                                     (call-with-values
                                       (lambda ()
                                         ((letrec ([f1134 (lambda (id*1135)
                                                            (if (null?
                                                                  id*1135)
                                                                (values
                                                                  '()
                                                                  '())
                                                                (call-with-values
                                                                  (lambda ()
                                                                    (f1134
                                                                      (cdr id*1135)))
                                                                  (lambda (sym*1137
                                                                           mark**1136)
                                                                    (values
                                                                      (cons
                                                                        (id->sym120
                                                                          (car id*1135))
                                                                        sym*1137)
                                                                      (cons
                                                                        (syntax-object-mark*80
                                                                          (car id*1135))
                                                                        mark**1136))))))])
                                            f1134)
                                           id*1131))
                                       (lambda (sym*1133 mark**1132)
                                         (make-rib98
                                           sym*1133
                                           mark**1132
                                           label*1130)))
                                     '#f))]
             [gen-label109 (lambda () (string '#\i))]
             [make-binding110 cons]
             [binding-type111 car]
             [binding-value112 cdr]
             [null-env113 '()]
             [extend-env114 (lambda (label1129 binding1128 r1127)
                              (cons (cons label1129 binding1128) r1127))]
             [extend-env*115 (lambda (label*1126 binding*1125 r1124)
                               (if (null? label*1126)
                                   r1124
                                   (extend-env*115
                                     (cdr label*1126)
                                     (cdr binding*1125)
                                     (extend-env114
                                       (car label*1126)
                                       (car binding*1125)
                                       r1124))))]
             [extend-var-env*116 (lambda (label*1123 var*1122 r1121)
                                   (if (null? label*1123)
                                       r1121
                                       (extend-var-env*116
                                         (cdr label*1123)
                                         (cdr var*1122)
                                         (extend-env114
                                           (car label*1123)
                                           (make-binding110
                                             'lexical
                                             (car var*1122))
                                           r1121))))]
             [displaced-lexical-error117 (lambda (id1120)
                                           (syntax-error
                                             id1120
                                             '"identifier out of context"))]
             [eval-transformer118 (lambda (x1118)
                                    ((lambda (x1119)
                                       (if (procedure? x1119)
                                           (make-binding110 'macro x1119)
                                           (if (if (pair? x1119)
                                                   (if (eq? (car x1119)
                                                            'macro!)
                                                       (procedure?
                                                         (cdr x1119))
                                                       '#f)
                                                   '#f)
                                               x1119
                                               (syntax-error
                                                 b
                                                 '"invalid transformer"))))
                                      (eval-hook0 x1118)))]
             [id?119 (lambda (x1117)
                       (if (syntax-object?78 x1117)
                           (id?119 (syntax-object-expression79 x1117))
                           (symbol? (unannotate87 x1117))))]
             [id->sym120 (lambda (x1116)
                           (if (syntax-object?78 x1116)
                               (id->sym120
                                 (syntax-object-expression79 x1116))
                               (unannotate87 x1116)))]
             [gen-var121 (lambda (id1115)
                           (build-lexical-var35
                             (source86 id1115)
                             (id->sym120 id1115)))]
             [id->label122 (lambda (id1106)
                             ((lambda (sym1107)
                                ((letrec ([search1108 (lambda (subst*1110
                                                               mark*1109)
                                                        (if (null?
                                                              subst*1110)
                                                            sym1107
                                                            ((lambda (subst1111)
                                                               (if (eq? subst1111
                                                                        'shift)
                                                                   (search1108
                                                                     (cdr subst*1110)
                                                                     (cdr mark*1109))
                                                                   ((letrec ([search-rib1112 (lambda (sym*1114
                                                                                                      i1113)
                                                                                               (if (null?
                                                                                                     sym*1114)
                                                                                                   (search1108
                                                                                                     (cdr subst*1110)
                                                                                                     mark*1109)
                                                                                                   (if (if (eq? (car sym*1114)
                                                                                                                sym1107)
                                                                                                           (same-marks?93
                                                                                                             mark*1109
                                                                                                             (list-ref
                                                                                                               (rib-mark**101
                                                                                                                 subst1111)
                                                                                                               i1113))
                                                                                                           '#f)
                                                                                                       (list-ref
                                                                                                         (rib-label*102
                                                                                                           subst1111)
                                                                                                         i1113)
                                                                                                       (search-rib1112
                                                                                                         (cdr sym*1114)
                                                                                                         (+ i1113
                                                                                                            '1)))))])
                                                                      search-rib1112)
                                                                     (rib-sym*100
                                                                       subst1111)
                                                                     '0)))
                                                              (car subst*1110))))])
                                   search1108)
                                  (syntax-object-subst*81 id1106)
                                  (syntax-object-mark*80 id1106)))
                               (id->sym120 id1106)))]
             [label->binding123 (lambda (x1104 r1103)
                                  (if (symbol? x1104)
                                      (global-lookup10 x1104)
                                      ((lambda (t1105)
                                         (if t1105
                                             (cdr t1105)
                                             (make-binding110
                                               'displaced-lexical
                                               '#f)))
                                        (assq x1104 r1103))))]
             [free-id=?124 (lambda (i1102 j1101)
                             (eq? (id->label122 i1102)
                                  (id->label122 j1101)))]
             [bound-id=?125 (lambda (i1100 j1099)
                              (if (eq? (id->sym120 i1100)
                                       (id->sym120 j1099))
                                  (same-marks?93
                                    (syntax-object-mark*80 i1100)
                                    (syntax-object-mark*80 j1099))
                                  '#f))]
             [bound-id-member?126 (lambda (x1097 list1096)
                                    (if (not (null? list1096))
                                        ((lambda (t1098)
                                           (if t1098
                                               t1098
                                               (bound-id-member?126
                                                 x1097
                                                 (cdr list1096))))
                                          (bound-id=?125
                                            x1097
                                            (car list1096)))
                                        '#f))]
             [valid-bound-ids?127 (lambda (id*1092)
                                    (if ((letrec ([all-ids?1093 (lambda (id*1094)
                                                                  ((lambda (t1095)
                                                                     (if t1095
                                                                         t1095
                                                                         (if (id?119
                                                                               (car id*1094))
                                                                             (all-ids?1093
                                                                               (cdr id*1094))
                                                                             '#f)))
                                                                    (null?
                                                                      id*1094)))])
                                           all-ids?1093)
                                          id*1092)
                                        (distinct-bound-ids?128 id*1092)
                                        '#f))]
             [distinct-bound-ids?128 (lambda (id*1088)
                                       ((letrec ([distinct?1089 (lambda (id*1090)
                                                                  ((lambda (t1091)
                                                                     (if t1091
                                                                         t1091
                                                                         (if (not (bound-id-member?126
                                                                                    (car id*1090)
                                                                                    (cdr id*1090)))
                                                                             (distinct?1089
                                                                               (cdr id*1090))
                                                                             '#f)))
                                                                    (null?
                                                                      id*1090)))])
                                          distinct?1089)
                                         id*1088))]
             [invalid-ids-error129 (lambda (id*1084 e1083 class1082)
                                     ((letrec ([find1085 (lambda (id*1087
                                                                  ok*1086)
                                                           (if (null?
                                                                 id*1087)
                                                               (syntax-error
                                                                 e1083)
                                                               (if (id?119
                                                                     (car id*1087))
                                                                   (if (bound-id-member?126
                                                                         (car id*1087)
                                                                         ok*1086)
                                                                       (syntax-error
                                                                         (car id*1087)
                                                                         '"duplicate "
                                                                         class1082)
                                                                       (find1085
                                                                         (cdr id*1087)
                                                                         (cons
                                                                           (car id*1087)
                                                                           ok*1086)))
                                                                   (syntax-error
                                                                     (car id*1087)
                                                                     '"invalid "
                                                                     class1082))))])
                                        find1085)
                                       id*1084
                                       '()))])
     (begin
       ((lambda ()
          (letrec* ([syntax-type595 (lambda (e1065 r1064)
                                      ((lambda (tmp1066)
                                         ((lambda (tmp1067)
                                            (if (if tmp1067
                                                    (apply
                                                      (lambda (id1068)
                                                        (id?119 id1068))
                                                      tmp1067)
                                                    '#f)
                                                (apply
                                                  (lambda (id1069)
                                                    ((lambda (label1070)
                                                       ((lambda (b1071)
                                                          ((lambda (type1072)
                                                             ((lambda (t1073)
                                                                (if (memv
                                                                      t1073
                                                                      '(macro
                                                                         macro!))
                                                                    (values
                                                                      type1072
                                                                      (binding-value112
                                                                        b1071)
                                                                      id1069)
                                                                    (if (memv
                                                                          t1073
                                                                          '(lexical
                                                                             global
                                                                             syntax
                                                                             displaced-lexical))
                                                                        (values
                                                                          type1072
                                                                          (binding-value112
                                                                            b1071)
                                                                          '#f)
                                                                        (values
                                                                          'other
                                                                          '#f
                                                                          '#f))))
                                                               type1072))
                                                            (binding-type111
                                                              b1071)))
                                                         (label->binding123
                                                           label1070
                                                           r1064)))
                                                      (id->label122
                                                        id1069)))
                                                  tmp1067)
                                                ((lambda (tmp1074)
                                                   (if tmp1074
                                                       (apply
                                                         (lambda (id1076
                                                                  rest1075)
                                                           (if (id?119
                                                                 id1076)
                                                               ((lambda (label1077)
                                                                  ((lambda (b1078)
                                                                     ((lambda (type1079)
                                                                        ((lambda (t1080)
                                                                           (if (memv
                                                                                 t1080
                                                                                 '(macro
                                                                                    macro!
                                                                                    core
                                                                                    begin
                                                                                    define
                                                                                    define-syntax
                                                                                    local-syntax))
                                                                               (values
                                                                                 type1079
                                                                                 (binding-value112
                                                                                   b1078)
                                                                                 id1076)
                                                                               (values
                                                                                 'call
                                                                                 '#f
                                                                                 '#f)))
                                                                          type1079))
                                                                       (binding-type111
                                                                         b1078)))
                                                                    (label->binding123
                                                                      label1077
                                                                      r1064)))
                                                                 (id->label122
                                                                   id1076))
                                                               (values
                                                                 'call
                                                                 '#f
                                                                 '#f)))
                                                         tmp1074)
                                                       ((lambda (d1081)
                                                          (if (self-evaluating?36
                                                                d1081)
                                                              (values
                                                                'constant
                                                                d1081
                                                                '#f)
                                                              (values
                                                                'other
                                                                '#f
                                                                '#f)))
                                                         (strip85
                                                           e1065
                                                           '()))))
                                                  ($syntax-dispatch
                                                    tmp1066
                                                    '(any . any)))))
                                           ($syntax-dispatch
                                             tmp1066
                                             'any)))
                                        e1065))]
                    [chi596 (lambda (e1056 r1055 mr1054)
                              (call-with-values
                                (lambda () (syntax-type595 e1056 r1055))
                                (lambda (type1059 value1058 kwd1057)
                                  ((lambda (t1060)
                                     (if (memv t1060 '(lexical))
                                         (build-lexical-reference26
                                           (source86 e1056)
                                           value1058)
                                         (if (memv t1060 '(global))
                                             (build-global-reference25
                                               (source86 e1056)
                                               value1058)
                                             (if (memv t1060 '(core))
                                                 (value1058
                                                   e1056
                                                   r1055
                                                   mr1054)
                                                 (if (memv
                                                       t1060
                                                       '(constant))
                                                     (build-data31
                                                       (source86 e1056)
                                                       value1058)
                                                     (if (memv
                                                           t1060
                                                           '(call))
                                                         (chi-application598
                                                           e1056
                                                           r1055
                                                           mr1054)
                                                         (if (memv
                                                               t1060
                                                               '(begin))
                                                             (build-sequence32
                                                               (source86
                                                                 e1056)
                                                               (chi-exprs597
                                                                 (parse-begin603
                                                                   e1056
                                                                   '#f)
                                                                 r1055
                                                                 mr1054))
                                                             (if (memv
                                                                   t1060
                                                                   '(macro
                                                                      macro!))
                                                                 (chi596
                                                                   (chi-macro599
                                                                     value1058
                                                                     e1056)
                                                                   r1055
                                                                   mr1054)
                                                                 (if (memv
                                                                       t1060
                                                                       '(local-syntax))
                                                                     (call-with-values
                                                                       (lambda ()
                                                                         (chi-local-syntax604
                                                                           value1058
                                                                           e1056
                                                                           r1055
                                                                           mr1054))
                                                                       (lambda (e*1063
                                                                                r1062
                                                                                mr1061)
                                                                         (build-sequence32
                                                                           (source86
                                                                             e1056)
                                                                           (chi-exprs597
                                                                             e*1063
                                                                             r1062
                                                                             mr1061))))
                                                                     (if (memv
                                                                           t1060
                                                                           '(define))
                                                                         (begin
                                                                           (parse-define601
                                                                             e1056)
                                                                           (syntax-error
                                                                             e1056
                                                                             '"invalid context for definition"))
                                                                         (if (memv
                                                                               t1060
                                                                               '(define-syntax))
                                                                             (begin
                                                                               (parse-define-syntax602
                                                                                 e1056)
                                                                               (syntax-error
                                                                                 e1056
                                                                                 '"invalid context for definition"))
                                                                             (if (memv
                                                                                   t1060
                                                                                   '(syntax))
                                                                                 (syntax-error
                                                                                   e1056
                                                                                   '"reference to pattern variable outside syntax form")
                                                                                 (if (memv
                                                                                       t1060
                                                                                       '(displaced-lexical))
                                                                                     (displaced-lexical-error117
                                                                                       e1056)
                                                                                     (syntax-error
                                                                                       e1056))))))))))))))
                                    type1059))))]
                    [chi-exprs597 (lambda (x*1052 r1051 mr1050)
                                    (map (lambda (x1053)
                                           (chi596 x1053 r1051 mr1050))
                                         x*1052))]
                    [chi-application598 (lambda (e1044 r1043 mr1042)
                                          ((lambda (tmp1045)
                                             ((lambda (tmp1046)
                                                (if tmp1046
                                                    (apply
                                                      (lambda (e01048
                                                               e11047)
                                                        (build-application11
                                                          (source86 e1044)
                                                          (chi596
                                                            e01048
                                                            r1043
                                                            mr1042)
                                                          (chi-exprs597
                                                            e11047
                                                            r1043
                                                            mr1042)))
                                                      tmp1046)
                                                    (syntax-error
                                                      tmp1045)))
                                               ($syntax-dispatch
                                                 tmp1045
                                                 '(any . each-any))))
                                            e1044))]
                    [chi-macro599 (lambda (p1041 e1040)
                                    (add-mark92
                                      (gen-mark90)
                                      (p1041
                                        (add-mark92 anti-mark91 e1040))))]
                    [chi-body600 (lambda (outer-e1012 e*1011 r1010 mr1009)
                                   ((lambda (rib1013)
                                      ((letrec ([parse1015 (lambda (e*1022
                                                                    r1021
                                                                    mr1020
                                                                    id*1019
                                                                    var*1018
                                                                    rhs*1017
                                                                    kwd*1016)
                                                             (if (null?
                                                                   e*1022)
                                                                 (syntax-error
                                                                   outer-e1012
                                                                   '"no expressions in body")
                                                                 ((lambda (e1023)
                                                                    (call-with-values
                                                                      (lambda ()
                                                                        (syntax-type595
                                                                          e1023
                                                                          r1021))
                                                                      (lambda (type1026
                                                                               value1025
                                                                               kwd1024)
                                                                        ((lambda (kwd*1027)
                                                                           ((lambda (t1028)
                                                                              (if (memv
                                                                                    t1028
                                                                                    '(define))
                                                                                  (call-with-values
                                                                                    (lambda ()
                                                                                      (parse-define601
                                                                                        e1023))
                                                                                    (lambda (id1030
                                                                                             rhs1029)
                                                                                      (begin
                                                                                        (if (bound-id-member?126
                                                                                              id1030
                                                                                              kwd*1027)
                                                                                            (syntax-error
                                                                                              id1030
                                                                                              '"undefined identifier")
                                                                                            (void))
                                                                                        ((lambda (label1032
                                                                                                  var1031)
                                                                                           (begin
                                                                                             (extend-rib!107
                                                                                               rib1013
                                                                                               id1030
                                                                                               label1032)
                                                                                             (parse1015
                                                                                               (cdr e*1022)
                                                                                               (extend-env114
                                                                                                 label1032
                                                                                                 (make-binding110
                                                                                                   'lexical
                                                                                                   var1031)
                                                                                                 r1021)
                                                                                               mr1020
                                                                                               (cons
                                                                                                 id1030
                                                                                                 id*1019)
                                                                                               (cons
                                                                                                 var1031
                                                                                                 var*1018)
                                                                                               (cons
                                                                                                 rhs1029
                                                                                                 rhs*1017)
                                                                                               kwd*1027)))
                                                                                          (gen-label109)
                                                                                          (gen-var121
                                                                                            id1030)))))
                                                                                  (if (memv
                                                                                        t1028
                                                                                        '(define-syntax))
                                                                                      (call-with-values
                                                                                        (lambda ()
                                                                                          (parse-define-syntax602
                                                                                            e1023))
                                                                                        (lambda (id1034
                                                                                                 rhs1033)
                                                                                          (begin
                                                                                            (if (bound-id-member?126
                                                                                                  id1034
                                                                                                  kwd*1027)
                                                                                                (syntax-error
                                                                                                  id1034
                                                                                                  '"undefined identifier")
                                                                                                (void))
                                                                                            ((lambda (label1035)
                                                                                               (begin
                                                                                                 (extend-rib!107
                                                                                                   rib1013
                                                                                                   id1034
                                                                                                   label1035)
                                                                                                 ((lambda (b1036)
                                                                                                    (parse1015
                                                                                                      (cdr e*1022)
                                                                                                      (extend-env114
                                                                                                        label1035
                                                                                                        b1036
                                                                                                        r1021)
                                                                                                      (extend-env114
                                                                                                        label1035
                                                                                                        b1036
                                                                                                        mr1020)
                                                                                                      (cons
                                                                                                        id1034
                                                                                                        id*1019)
                                                                                                      var*1018
                                                                                                      rhs*1017
                                                                                                      kwd*1027))
                                                                                                   (eval-transformer118
                                                                                                     (chi596
                                                                                                       rhs1033
                                                                                                       mr1020
                                                                                                       mr1020)))))
                                                                                              (gen-label109)))))
                                                                                      (if (memv
                                                                                            t1028
                                                                                            '(begin))
                                                                                          (parse1015
                                                                                            (append
                                                                                              (parse-begin603
                                                                                                e1023
                                                                                                '#t)
                                                                                              (cdr e*1022))
                                                                                            r1021
                                                                                            mr1020
                                                                                            id*1019
                                                                                            var*1018
                                                                                            rhs*1017
                                                                                            kwd*1027)
                                                                                          (if (memv
                                                                                                t1028
                                                                                                '(macro
                                                                                                   macro!))
                                                                                              (parse1015
                                                                                                (cons
                                                                                                  (add-subst95
                                                                                                    rib1013
                                                                                                    (chi-macro599
                                                                                                      value1025
                                                                                                      e1023))
                                                                                                  (cdr e*1022))
                                                                                                r1021
                                                                                                mr1020
                                                                                                id*1019
                                                                                                var*1018
                                                                                                rhs*1017
                                                                                                kwd*1027)
                                                                                              (if (memv
                                                                                                    t1028
                                                                                                    '(local-syntax))
                                                                                                  (call-with-values
                                                                                                    (lambda ()
                                                                                                      (chi-local-syntax604
                                                                                                        value1025
                                                                                                        e1023
                                                                                                        r1021
                                                                                                        mr1020))
                                                                                                    (lambda (new-e*1039
                                                                                                             r1038
                                                                                                             mr1037)
                                                                                                      (parse1015
                                                                                                        (append
                                                                                                          new-e*1039
                                                                                                          (cdr e*1022))
                                                                                                        r1038
                                                                                                        mr1037
                                                                                                        id*1019
                                                                                                        var*1018
                                                                                                        rhs*1017
                                                                                                        kwd*1027)))
                                                                                                  (begin
                                                                                                    (if (not (valid-bound-ids?127
                                                                                                               id*1019))
                                                                                                        (invalid-ids-error129
                                                                                                          id*1019
                                                                                                          outer-e1012
                                                                                                          '"locally defined identifier")
                                                                                                        (void))
                                                                                                    (build-letrec*34
                                                                                                      no-source3
                                                                                                      (reverse
                                                                                                        var*1018)
                                                                                                      (chi-exprs597
                                                                                                        (reverse
                                                                                                          rhs*1017)
                                                                                                        r1021
                                                                                                        mr1020)
                                                                                                      (build-sequence32
                                                                                                        no-source3
                                                                                                        (chi-exprs597
                                                                                                          (cons
                                                                                                            e1023
                                                                                                            (cdr e*1022))
                                                                                                          r1021
                                                                                                          mr1020))))))))))
                                                                             type1026))
                                                                          (cons
                                                                            kwd1024
                                                                            kwd*1016)))))
                                                                   (car e*1022))))])
                                         parse1015)
                                        (map (lambda (e1014)
                                               (add-subst95 rib1013 e1014))
                                             e*1011)
                                        r1010 mr1009 '() '() '() '()))
                                     (make-empty-rib106)))]
                    [parse-define601 (lambda (e978)
                                       (letrec* ([valid-args?979 (lambda (args999)
                                                                   (valid-bound-ids?127
                                                                     ((lambda (tmp1000)
                                                                        ((lambda (tmp1001)
                                                                           (if tmp1001
                                                                               (apply
                                                                                 (lambda (id1002)
                                                                                   id1002)
                                                                                 tmp1001)
                                                                               ((lambda (tmp1004)
                                                                                  (if tmp1004
                                                                                      (apply
                                                                                        (lambda (id1006
                                                                                                 r1005)
                                                                                          (append
                                                                                            id1006
                                                                                            (cons
                                                                                              r1005
                                                                                              '#(syntax-object
                                                                                                 ()
                                                                                                 (top)
                                                                                                 ()))))
                                                                                        tmp1004)
                                                                                      ((lambda (id1008)
                                                                                         (cons
                                                                                           id1008
                                                                                           '#(syntax-object
                                                                                              ()
                                                                                              (top)
                                                                                              ())))
                                                                                        tmp1000)))
                                                                                 ($syntax-dispatch
                                                                                   tmp1000
                                                                                   '#(each+
                                                                                      any
                                                                                      ()
                                                                                      any)))))
                                                                          ($syntax-dispatch
                                                                            tmp1000
                                                                            'each-any)))
                                                                       args999)))])
                                         ((lambda (tmp980)
                                            ((lambda (tmp981)
                                               (if (if tmp981
                                                       (apply
                                                         (lambda (name983
                                                                  e982)
                                                           (id?119
                                                             name983))
                                                         tmp981)
                                                       '#f)
                                                   (apply
                                                     (lambda (name985 e984)
                                                       (values
                                                         name985
                                                         e984))
                                                     tmp981)
                                                   ((lambda (tmp986)
                                                      (if (if tmp986
                                                              (apply
                                                                (lambda (name990
                                                                         args989
                                                                         e1988
                                                                         e2987)
                                                                  (if (id?119
                                                                        name990)
                                                                      (valid-args?979
                                                                        args989)
                                                                      '#f))
                                                                tmp986)
                                                              '#f)
                                                          (apply
                                                            (lambda (name994
                                                                     args993
                                                                     e1992
                                                                     e2991)
                                                              (values
                                                                name994
                                                                (cons
                                                                  '#(syntax-object
                                                                     lambda
                                                                     (top)
                                                                     ())
                                                                  (cons
                                                                    args993
                                                                    (cons
                                                                      e1992
                                                                      e2991)))))
                                                            tmp986)
                                                          ((lambda (tmp996)
                                                             (if (if tmp996
                                                                     (apply
                                                                       (lambda (name997)
                                                                         (id?119
                                                                           name997))
                                                                       tmp996)
                                                                     '#f)
                                                                 (apply
                                                                   (lambda (name998)
                                                                     (values
                                                                       name998
                                                                       '#(syntax-object
                                                                          (void)
                                                                          (top)
                                                                          ())))
                                                                   tmp996)
                                                                 (syntax-error
                                                                   tmp980)))
                                                            ($syntax-dispatch
                                                              tmp980
                                                              '(_ any)))))
                                                     ($syntax-dispatch
                                                       tmp980
                                                       '(_ (any . any)
                                                           any
                                                           .
                                                           each-any)))))
                                              ($syntax-dispatch
                                                tmp980
                                                '(_ any any))))
                                           e978)))]
                    [parse-define-syntax602 (lambda (e971)
                                              ((lambda (tmp972)
                                                 ((lambda (tmp973)
                                                    (if (if tmp973
                                                            (apply
                                                              (lambda (name975
                                                                       rhs974)
                                                                (id?119
                                                                  name975))
                                                              tmp973)
                                                            '#f)
                                                        (apply
                                                          (lambda (name977
                                                                   rhs976)
                                                            (values
                                                              name977
                                                              rhs976))
                                                          tmp973)
                                                        (syntax-error
                                                          tmp972)))
                                                   ($syntax-dispatch
                                                     tmp972
                                                     '(_ any any))))
                                                e971))]
                    [parse-begin603 (lambda (e964 empty-okay?963)
                                      ((lambda (tmp965)
                                         ((lambda (tmp966)
                                            (if (if tmp966
                                                    (apply
                                                      (lambda ()
                                                        empty-okay?963)
                                                      tmp966)
                                                    '#f)
                                                (apply
                                                  (lambda () '())
                                                  tmp966)
                                                ((lambda (tmp967)
                                                   (if tmp967
                                                       (apply
                                                         (lambda (e1969
                                                                  e2968)
                                                           (cons
                                                             e1969
                                                             e2968))
                                                         tmp967)
                                                       (syntax-error
                                                         tmp965)))
                                                  ($syntax-dispatch
                                                    tmp965
                                                    '(_ any . each-any)))))
                                           ($syntax-dispatch tmp965 '(_))))
                                        e964))]
                    [chi-local-syntax604 (lambda (rec?944 e943 r942 mr941)
                                           ((lambda (tmp945)
                                              ((lambda (tmp946)
                                                 (if tmp946
                                                     (apply
                                                       (lambda (id950
                                                                rhs949
                                                                e1948
                                                                e2947)
                                                         ((lambda (id*954
                                                                   rhs*953)
                                                            (begin
                                                              (if (not (valid-bound-ids?127
                                                                         id*954))
                                                                  (invalid-ids-error129
                                                                    id*954
                                                                    e943
                                                                    '"keyword")
                                                                  (void))
                                                              ((lambda (label*956)
                                                                 ((lambda (rib957)
                                                                    ((lambda (b*960)
                                                                       (values
                                                                         (map (lambda (e962)
                                                                                (add-subst95
                                                                                  rib957
                                                                                  e962))
                                                                              (cons
                                                                                e1948
                                                                                e2947))
                                                                         (extend-env*115
                                                                           label*956
                                                                           b*960
                                                                           r942)
                                                                         (extend-env*115
                                                                           label*956
                                                                           b*960
                                                                           mr941)))
                                                                      (map (lambda (x959)
                                                                             (eval-transformer118
                                                                               (chi596
                                                                                 x959
                                                                                 mr941
                                                                                 mr941)))
                                                                           (if rec?944
                                                                               (map (lambda (x958)
                                                                                      (add-subst95
                                                                                        rib957
                                                                                        x958))
                                                                                    rhs*953)
                                                                               rhs*953))))
                                                                   (make-full-rib108
                                                                     id*954
                                                                     label*956)))
                                                                (map (lambda (x955)
                                                                       (gen-label109))
                                                                     id*954))))
                                                           id950
                                                           rhs949))
                                                       tmp946)
                                                     (syntax-error
                                                       tmp945)))
                                                ($syntax-dispatch
                                                  tmp945
                                                  '(_ #(each (any any))
                                                      any
                                                      .
                                                      each-any))))
                                             e943))]
                    [ellipsis?605 (lambda (x940)
                                    (if (id?119 x940)
                                        (free-id=?124
                                          x940
                                          '#(syntax-object ... (top) ()))
                                        '#f))])
            (begin
              (set! sc-expand
                (lambda (x939)
                  (chi596
                    (syntax-object97 x939 top-mark*88 top-subst*94)
                    null-env113
                    null-env113)))
              (global-extend9 'begin 'begin '#f)
              (global-extend9 'define 'define '#f)
              (global-extend9 'define-syntax 'define-syntax '#f)
              (global-extend9 'local-syntax 'letrec-syntax '#t)
              (global-extend9 'local-syntax 'let-syntax '#f)
              (global-extend9
                'core
                'quote
                (lambda (e935 r934 mr933)
                  ((lambda (tmp936)
                     ((lambda (tmp937)
                        (if tmp937
                            (apply
                              (lambda (e938)
                                (build-data31
                                  (source86 e938)
                                  (strip85 e938 '())))
                              tmp937)
                            (syntax-error tmp936)))
                       ($syntax-dispatch tmp936 '(_ any))))
                    e935)))
              (global-extend9
                'core
                'lambda
                (lambda (e904 r903 mr902)
                  (letrec* ([help905 (lambda (var*927 rest?926 e*925)
                                       (begin
                                         (if (not (valid-bound-ids?127
                                                    var*927))
                                             (invalid-ids-error129
                                               var*927
                                               e904
                                               '"parameter")
                                             (void))
                                         ((lambda (label*930 new-var*929)
                                            (build-lambda29
                                              (source86 e904)
                                              new-var*929
                                              rest?926
                                              (chi-body600
                                                e904
                                                ((lambda (rib931)
                                                   (map (lambda (e932)
                                                          (add-subst95
                                                            rib931
                                                            e932))
                                                        e*925))
                                                  (make-full-rib108
                                                    var*927
                                                    label*930))
                                                (extend-var-env*116
                                                  label*930
                                                  new-var*929
                                                  r903)
                                                mr902)))
                                           (map (lambda (x928)
                                                  (gen-label109))
                                                var*927)
                                           (map gen-var121 var*927))))])
                    ((lambda (tmp906)
                       ((lambda (tmp907)
                          (if tmp907
                              (apply
                                (lambda (var910 e1909 e2908)
                                  (help905 var910 '#f (cons e1909 e2908)))
                                tmp907)
                              ((lambda (tmp913)
                                 (if tmp913
                                     (apply
                                       (lambda (var917 rvar916 e1915 e2914)
                                         (help905
                                           (append
                                             var917
                                             (cons rvar916 '()))
                                           '#t
                                           (cons e1915 e2914)))
                                       tmp913)
                                     ((lambda (tmp920)
                                        (if tmp920
                                            (apply
                                              (lambda (var923 e1922 e2921)
                                                (help905
                                                  (cons var923 '())
                                                  '#t
                                                  (cons e1922 e2921)))
                                              tmp920)
                                            (syntax-error tmp906)))
                                       ($syntax-dispatch
                                         tmp906
                                         '(_ any any . each-any)))))
                                ($syntax-dispatch
                                  tmp906
                                  '(_ #(each+ any () any)
                                      any
                                      .
                                      each-any)))))
                         ($syntax-dispatch
                           tmp906
                           '(_ each-any any . each-any))))
                      e904))))
              (global-extend9
                'core
                'letrec
                (lambda (e882 r881 mr880)
                  ((lambda (tmp883)
                     ((lambda (tmp884)
                        (if tmp884
                            (apply
                              (lambda (var888 rhs887 e1886 e2885)
                                ((lambda (var*894 rhs*893 e*892)
                                   (begin
                                     (if (not (valid-bound-ids?127
                                                var*894))
                                         (invalid-ids-error129
                                           var*894
                                           e882
                                           '"bound variable")
                                         (void))
                                     ((lambda (label*897 new-var*896)
                                        ((lambda (r899 rib898)
                                           (build-letrec33
                                             (source86 e882)
                                             new-var*896
                                             (map (lambda (e901)
                                                    (chi596
                                                      (add-subst95
                                                        rib898
                                                        e901)
                                                      r899
                                                      mr880))
                                                  rhs*893)
                                             (chi-body600
                                               e882
                                               (map (lambda (e900)
                                                      (add-subst95
                                                        rib898
                                                        e900))
                                                    e*892)
                                               r899
                                               mr880)))
                                          (extend-var-env*116
                                            label*897
                                            new-var*896
                                            r881)
                                          (make-full-rib108
                                            var*894
                                            label*897)))
                                       (map (lambda (x895) (gen-label109))
                                            var*894)
                                       (map gen-var121 var*894))))
                                  var888
                                  rhs887
                                  (cons e1886 e2885)))
                              tmp884)
                            (syntax-error tmp883)))
                       ($syntax-dispatch
                         tmp883
                         '(_ #(each (any any)) any . each-any))))
                    e882)))
              (global-extend9
                'core
                'letrec*
                (lambda (e860 r859 mr858)
                  ((lambda (tmp861)
                     ((lambda (tmp862)
                        (if tmp862
                            (apply
                              (lambda (var866 rhs865 e1864 e2863)
                                ((lambda (var*872 rhs*871 e*870)
                                   (begin
                                     (if (not (valid-bound-ids?127
                                                var*872))
                                         (invalid-ids-error129
                                           var*872
                                           e860
                                           '"bound variable")
                                         (void))
                                     ((lambda (label*875 new-var*874)
                                        ((lambda (r877 rib876)
                                           (build-letrec*34
                                             (source86 e860)
                                             new-var*874
                                             (map (lambda (e879)
                                                    (chi596
                                                      (add-subst95
                                                        rib876
                                                        e879)
                                                      r877
                                                      mr858))
                                                  rhs*871)
                                             (chi-body600
                                               e860
                                               (map (lambda (e878)
                                                      (add-subst95
                                                        rib876
                                                        e878))
                                                    e*870)
                                               r877
                                               mr858)))
                                          (extend-var-env*116
                                            label*875
                                            new-var*874
                                            r859)
                                          (make-full-rib108
                                            var*872
                                            label*875)))
                                       (map (lambda (x873) (gen-label109))
                                            var*872)
                                       (map gen-var121 var*872))))
                                  var866
                                  rhs865
                                  (cons e1864 e2863)))
                              tmp862)
                            (syntax-error tmp861)))
                       ($syntax-dispatch
                         tmp861
                         '(_ #(each (any any)) any . each-any))))
                    e860)))
              (global-extend9
                'core
                'set!
                (lambda (e849 r848 mr847)
                  ((lambda (tmp850)
                     ((lambda (tmp851)
                        (if (if tmp851
                                (apply
                                  (lambda (id853 rhs852) (id?119 id853))
                                  tmp851)
                                '#f)
                            (apply
                              (lambda (id855 rhs854)
                                ((lambda (b856)
                                   ((lambda (t857)
                                      (if (memv t857 '(macro!))
                                          (chi596
                                            (chi-macro599
                                              (binding-value112 b856)
                                              e849)
                                            r848
                                            mr847)
                                          (if (memv t857 '(lexical))
                                              (build-lexical-assignment27
                                                (source86 e849)
                                                (binding-value112 b856)
                                                (chi596 rhs854 r848 mr847))
                                              (if (memv t857 '(global))
                                                  (build-global-assignment28
                                                    (source86 e849)
                                                    (binding-value112 b856)
                                                    (chi596
                                                      rhs854
                                                      r848
                                                      mr847))
                                                  (if (memv
                                                        t857
                                                        '(displaced-lexical))
                                                      (displaced-lexical-error117
                                                        id855)
                                                      (syntax-error
                                                        e849))))))
                                     (binding-type111 b856)))
                                  (label->binding123
                                    (id->label122 id855)
                                    r848)))
                              tmp851)
                            (syntax-error tmp850)))
                       ($syntax-dispatch tmp850 '(_ any any))))
                    e849)))
              (global-extend9
                'core
                'if
                (lambda (e838 r837 mr836)
                  ((lambda (tmp839)
                     ((lambda (tmp840)
                        (if tmp840
                            (apply
                              (lambda (test842 then841)
                                (cons
                                  'if
                                  (cons
                                    (chi596 test842 r837 mr836)
                                    (cons
                                      (chi596 then841 r837 mr836)
                                      '((void))))))
                              tmp840)
                            ((lambda (tmp843)
                               (if tmp843
                                   (apply
                                     (lambda (test846 then845 else844)
                                       (cons
                                         'if
                                         (cons
                                           (chi596 test846 r837 mr836)
                                           (cons
                                             (chi596 then845 r837 mr836)
                                             (cons
                                               (chi596 else844 r837 mr836)
                                               '())))))
                                     tmp843)
                                   (syntax-error tmp839)))
                              ($syntax-dispatch tmp839 '(_ any any any)))))
                       ($syntax-dispatch tmp839 '(_ any any))))
                    e838)))
              (global-extend9
                'core
                'syntax-case
                ((lambda ()
                   (letrec* ([convert-pattern726 (lambda (pattern785
                                                          keys784)
                                                   (letrec* ([cvt*786 (lambda (p*831
                                                                               n830
                                                                               ids829)
                                                                        (if (null?
                                                                              p*831)
                                                                            (values
                                                                              '()
                                                                              ids829)
                                                                            (call-with-values
                                                                              (lambda ()
                                                                                (cvt*786
                                                                                  (cdr p*831)
                                                                                  n830
                                                                                  ids829))
                                                                              (lambda (y833
                                                                                       ids832)
                                                                                (call-with-values
                                                                                  (lambda ()
                                                                                    (cvt787
                                                                                      (car p*831)
                                                                                      n830
                                                                                      ids832))
                                                                                  (lambda (x835
                                                                                           ids834)
                                                                                    (values
                                                                                      (cons
                                                                                        x835
                                                                                        y833)
                                                                                      ids834)))))))]
                                                             [cvt787 (lambda (p790
                                                                              n789
                                                                              ids788)
                                                                       (if (not (id?119
                                                                                  p790))
                                                                           ((lambda (tmp791)
                                                                              ((lambda (tmp792)
                                                                                 (if (if tmp792
                                                                                         (apply
                                                                                           (lambda (x794
                                                                                                    dots793)
                                                                                             (ellipsis?605
                                                                                               dots793))
                                                                                           tmp792)
                                                                                         '#f)
                                                                                     (apply
                                                                                       (lambda (x796
                                                                                                dots795)
                                                                                         (call-with-values
                                                                                           (lambda ()
                                                                                             (cvt787
                                                                                               x796
                                                                                               (+ n789
                                                                                                  '1)
                                                                                               ids788))
                                                                                           (lambda (p798
                                                                                                    ids797)
                                                                                             (values
                                                                                               (if (eq? p798
                                                                                                        'any)
                                                                                                   'each-any
                                                                                                   (vector
                                                                                                     'each
                                                                                                     p798))
                                                                                               ids797))))
                                                                                       tmp792)
                                                                                     ((lambda (tmp799)
                                                                                        (if (if tmp799
                                                                                                (apply
                                                                                                  (lambda (x803
                                                                                                           dots802
                                                                                                           y801
                                                                                                           z800)
                                                                                                    (ellipsis?605
                                                                                                      dots802))
                                                                                                  tmp799)
                                                                                                '#f)
                                                                                            (apply
                                                                                              (lambda (x807
                                                                                                       dots806
                                                                                                       y805
                                                                                                       z804)
                                                                                                (call-with-values
                                                                                                  (lambda ()
                                                                                                    (cvt787
                                                                                                      z804
                                                                                                      n789
                                                                                                      ids788))
                                                                                                  (lambda (z809
                                                                                                           ids808)
                                                                                                    (call-with-values
                                                                                                      (lambda ()
                                                                                                        (cvt*786
                                                                                                          y805
                                                                                                          n789
                                                                                                          ids808))
                                                                                                      (lambda (y811
                                                                                                               ids810)
                                                                                                        (call-with-values
                                                                                                          (lambda ()
                                                                                                            (cvt787
                                                                                                              x807
                                                                                                              (+ n789
                                                                                                                 '1)
                                                                                                              ids810))
                                                                                                          (lambda (x813
                                                                                                                   ids812)
                                                                                                            (values
                                                                                                              (list->vector
                                                                                                                (cons
                                                                                                                  'each+
                                                                                                                  (cons
                                                                                                                    x813
                                                                                                                    (cons
                                                                                                                      (reverse
                                                                                                                        y811)
                                                                                                                      (list
                                                                                                                        z809)))))
                                                                                                              ids812))))))))
                                                                                              tmp799)
                                                                                            ((lambda (tmp815)
                                                                                               (if tmp815
                                                                                                   (apply
                                                                                                     (lambda (x817
                                                                                                              y816)
                                                                                                       (call-with-values
                                                                                                         (lambda ()
                                                                                                           (cvt787
                                                                                                             y816
                                                                                                             n789
                                                                                                             ids788))
                                                                                                         (lambda (y819
                                                                                                                  ids818)
                                                                                                           (call-with-values
                                                                                                             (lambda ()
                                                                                                               (cvt787
                                                                                                                 x817
                                                                                                                 n789
                                                                                                                 ids818))
                                                                                                             (lambda (x821
                                                                                                                      ids820)
                                                                                                               (values
                                                                                                                 (cons
                                                                                                                   x821
                                                                                                                   y819)
                                                                                                                 ids820))))))
                                                                                                     tmp815)
                                                                                                   ((lambda (tmp822)
                                                                                                      (if tmp822
                                                                                                          (apply
                                                                                                            (lambda ()
                                                                                                              (values
                                                                                                                '()
                                                                                                                ids788))
                                                                                                            tmp822)
                                                                                                          ((lambda (tmp823)
                                                                                                             (if tmp823
                                                                                                                 (apply
                                                                                                                   (lambda (x824)
                                                                                                                     (call-with-values
                                                                                                                       (lambda ()
                                                                                                                         (cvt787
                                                                                                                           x824
                                                                                                                           n789
                                                                                                                           ids788))
                                                                                                                       (lambda (p826
                                                                                                                                ids825)
                                                                                                                         (values
                                                                                                                           (vector
                                                                                                                             'vector
                                                                                                                             p826)
                                                                                                                           ids825))))
                                                                                                                   tmp823)
                                                                                                                 ((lambda (x828)
                                                                                                                    (values
                                                                                                                      (vector
                                                                                                                        'atom
                                                                                                                        (strip85
                                                                                                                          p790
                                                                                                                          '()))
                                                                                                                      ids788))
                                                                                                                   tmp791)))
                                                                                                            ($syntax-dispatch
                                                                                                              tmp791
                                                                                                              '#(vector
                                                                                                                 each-any)))))
                                                                                                     ($syntax-dispatch
                                                                                                       tmp791
                                                                                                       '()))))
                                                                                              ($syntax-dispatch
                                                                                                tmp791
                                                                                                '(any .
                                                                                                      any)))))
                                                                                       ($syntax-dispatch
                                                                                         tmp791
                                                                                         '(any any
                                                                                               .
                                                                                               #(each+
                                                                                                 any
                                                                                                 ()
                                                                                                 any))))))
                                                                                ($syntax-dispatch
                                                                                  tmp791
                                                                                  '(any any))))
                                                                             p790)
                                                                           (if (bound-id-member?126
                                                                                 p790
                                                                                 keys784)
                                                                               (values
                                                                                 (vector
                                                                                   'free-id
                                                                                   p790)
                                                                                 ids788)
                                                                               (if (free-id=?124
                                                                                     p790
                                                                                     '#(syntax-object
                                                                                        _
                                                                                        (top)
                                                                                        ()))
                                                                                   (values
                                                                                     '_
                                                                                     ids788)
                                                                                   (values
                                                                                     'any
                                                                                     (cons
                                                                                       (cons
                                                                                         p790
                                                                                         n789)
                                                                                       ids788))))))])
                                                     (cvt787
                                                       pattern785
                                                       '0
                                                       '())))]
                             [build-dispatch-call727 (lambda (pvars776
                                                              expr775 y774
                                                              r773 mr772)
                                                       ((lambda (ids778
                                                                 levels777)
                                                          ((lambda (labels781
                                                                    new-vars780)
                                                             (build-application11
                                                               no-source3
                                                               (build-primref30
                                                                 no-source3
                                                                 'apply)
                                                               (list
                                                                 (build-lambda29
                                                                   no-source3
                                                                   new-vars780
                                                                   '#f
                                                                   (chi596
                                                                     (add-subst95
                                                                       (make-full-rib108
                                                                         ids778
                                                                         labels781)
                                                                       expr775)
                                                                     (extend-env*115
                                                                       labels781
                                                                       (map (lambda (var783
                                                                                     level782)
                                                                              (make-binding110
                                                                                'syntax
                                                                                (cons
                                                                                  var783
                                                                                  level782)))
                                                                            new-vars780
                                                                            (map cdr
                                                                                 pvars776))
                                                                       r773)
                                                                     mr772))
                                                                 y774)))
                                                            (map (lambda (x779)
                                                                   (gen-label109))
                                                                 ids778)
                                                            (map gen-var121
                                                                 ids778)))
                                                         (map car pvars776)
                                                         (map cdr
                                                              pvars776)))]
                             [gen-clause728 (lambda (x765 keys764
                                                     clauses763 r762 mr761
                                                     pat760 fender759
                                                     expr758)
                                              (call-with-values
                                                (lambda ()
                                                  (convert-pattern726
                                                    pat760
                                                    keys764))
                                                (lambda (p767 pvars766)
                                                  (if (not (distinct-bound-ids?128
                                                             (map car
                                                                  pvars766)))
                                                      (invalid-ids-error129
                                                        (map car pvars766)
                                                        pat760
                                                        '"pattern variable")
                                                      (if (not (andmap37
                                                                 (lambda (x768)
                                                                   (not (ellipsis?605
                                                                          (car x768))))
                                                                 pvars766))
                                                          (syntax-error
                                                            pat760
                                                            '"misplaced ellipsis in syntax-case pattern")
                                                          ((lambda (y769)
                                                             (build-application11
                                                               no-source3
                                                               (build-lambda29
                                                                 no-source3
                                                                 (list
                                                                   y769)
                                                                 '#f
                                                                 (cons
                                                                   'if
                                                                   (cons
                                                                     ((lambda (tmp770)
                                                                        ((lambda (tmp771)
                                                                           (if tmp771
                                                                               (apply
                                                                                 (lambda ()
                                                                                   y769)
                                                                                 tmp771)
                                                                               (cons
                                                                                 'if
                                                                                 (cons
                                                                                   (build-lexical-reference26
                                                                                     no-source3
                                                                                     y769)
                                                                                   (cons
                                                                                     (build-dispatch-call727
                                                                                       pvars766
                                                                                       fender759
                                                                                       y769
                                                                                       r762
                                                                                       mr761)
                                                                                     (cons
                                                                                       (build-data31
                                                                                         no-source3
                                                                                         '#f)
                                                                                       '()))))))
                                                                          ($syntax-dispatch
                                                                            tmp770
                                                                            '#(atom
                                                                               #t))))
                                                                       fender759)
                                                                     (cons
                                                                       (build-dispatch-call727
                                                                         pvars766
                                                                         expr758
                                                                         (build-lexical-reference26
                                                                           no-source3
                                                                           y769)
                                                                         r762
                                                                         mr761)
                                                                       (cons
                                                                         (gen-syntax-case729
                                                                           x765
                                                                           keys764
                                                                           clauses763
                                                                           r762
                                                                           mr761)
                                                                         '())))))
                                                               (list
                                                                 (build-application11
                                                                   no-source3
                                                                   (build-primref30
                                                                     no-source3
                                                                     '$syntax-dispatch)
                                                                   (list
                                                                     (build-lexical-reference26
                                                                       no-source3
                                                                       x765)
                                                                     (build-data31
                                                                       no-source3
                                                                       p767))))))
                                                            (gen-var121
                                                              '#(syntax-object
                                                                 tmp (top)
                                                                 ()))))))))]
                             [gen-syntax-case729 (lambda (x747 keys746
                                                          clauses745 r744
                                                          mr743)
                                                   (if (null? clauses745)
                                                       (build-application11
                                                         no-source3
                                                         (build-primref30
                                                           no-source3
                                                           'syntax-error)
                                                         (list
                                                           (build-lexical-reference26
                                                             no-source3
                                                             x747)))
                                                       ((lambda (tmp748)
                                                          ((lambda (tmp749)
                                                             (if tmp749
                                                                 (apply
                                                                   (lambda (pat751
                                                                            expr750)
                                                                     (if (if (id?119
                                                                               pat751)
                                                                             (if (not (bound-id-member?126
                                                                                        pat751
                                                                                        keys746))
                                                                                 (not (ellipsis?605
                                                                                        pat751))
                                                                                 '#f)
                                                                             '#f)
                                                                         (if (free-identifier=?
                                                                               pat751
                                                                               '#(syntax-object
                                                                                  _
                                                                                  (top)
                                                                                  ()))
                                                                             (chi596
                                                                               expr750
                                                                               r744
                                                                               mr743)
                                                                             ((lambda (label753
                                                                                       var752)
                                                                                (build-application11
                                                                                  no-source3
                                                                                  (build-lambda29
                                                                                    no-source3
                                                                                    (list
                                                                                      var752)
                                                                                    '#f
                                                                                    (chi596
                                                                                      (add-subst95
                                                                                        (make-full-rib108
                                                                                          (list
                                                                                            pat751)
                                                                                          (list
                                                                                            label753))
                                                                                        expr750)
                                                                                      (extend-env114
                                                                                        label753
                                                                                        (make-binding110
                                                                                          'syntax
                                                                                          (cons
                                                                                            var752
                                                                                            '0))
                                                                                        r744)
                                                                                      mr743))
                                                                                  (list
                                                                                    (build-lexical-reference26
                                                                                      no-source3
                                                                                      x747))))
                                                                               (gen-label109)
                                                                               (gen-var121
                                                                                 pat751)))
                                                                         (gen-clause728
                                                                           x747
                                                                           keys746
                                                                           (cdr clauses745)
                                                                           r744
                                                                           mr743
                                                                           pat751
                                                                           '#t
                                                                           expr750)))
                                                                   tmp749)
                                                                 ((lambda (tmp754)
                                                                    (if tmp754
                                                                        (apply
                                                                          (lambda (pat757
                                                                                   fender756
                                                                                   expr755)
                                                                            (gen-clause728
                                                                              x747
                                                                              keys746
                                                                              (cdr clauses745)
                                                                              r744
                                                                              mr743
                                                                              pat757
                                                                              fender756
                                                                              expr755))
                                                                          tmp754)
                                                                        (syntax-error
                                                                          (car clauses745)
                                                                          '"invalid syntax-case clause")))
                                                                   ($syntax-dispatch
                                                                     tmp748
                                                                     '(any any
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp748
                                                              '(any any))))
                                                         (car clauses745))))])
                     (lambda (e732 r731 mr730)
                       ((lambda (tmp733)
                          ((lambda (tmp734)
                             (if tmp734
                                 (apply
                                   (lambda (expr737 key736 m735)
                                     (if (andmap37
                                           (lambda (x739)
                                             (if (id?119 x739)
                                                 (not (ellipsis?605 x739))
                                                 '#f))
                                           key736)
                                         ((lambda (x740)
                                            (build-application11
                                              (source86 e732)
                                              (build-lambda29
                                                no-source3
                                                (list x740)
                                                '#f
                                                (gen-syntax-case729 x740
                                                  key736 m735 r731 mr730))
                                              (list
                                                (chi596
                                                  expr737
                                                  r731
                                                  mr730))))
                                           (gen-var121
                                             '#(syntax-object tmp (top)
                                                ())))
                                         (syntax-error
                                           e732
                                           '"invalid literals list in")))
                                   tmp734)
                                 (syntax-error tmp733)))
                            ($syntax-dispatch
                              tmp733
                              '(_ any each-any . each-any))))
                         e732))))))
              ((lambda ()
                 (letrec* ([gen-syntax606 (lambda (src671 e670 r669 maps668
                                                   ellipsis?667 vec?666
                                                   fm665)
                                            (if (id?119 e670)
                                                ((lambda (label672)
                                                   ((lambda (b673)
                                                      (if (eq? (binding-type111
                                                                 b673)
                                                               'syntax)
                                                          (call-with-values
                                                            (lambda ()
                                                              ((lambda (var.lev676)
                                                                 (gen-ref607
                                                                   src671
                                                                   (car var.lev676)
                                                                   (cdr var.lev676)
                                                                   maps668))
                                                                (binding-value112
                                                                  b673)))
                                                            (lambda (var675
                                                                     maps674)
                                                              (values
                                                                (cons
                                                                  'ref
                                                                  (cons
                                                                    var675
                                                                    '()))
                                                                maps674)))
                                                          (if (ellipsis?667
                                                                e670)
                                                              (syntax-error
                                                                src671
                                                                '"misplaced ellipsis in syntax form")
                                                              (values
                                                                (cons
                                                                  'quote
                                                                  (cons
                                                                    (if fm665
                                                                        (add-mark92
                                                                          anti-mark91
                                                                          (add-mark92
                                                                            fm665
                                                                            e670))
                                                                        e670)
                                                                    '()))
                                                                maps668))))
                                                     (label->binding123
                                                       label672
                                                       r669)))
                                                  (id->label122 e670))
                                                ((lambda (tmp677)
                                                   ((lambda (tmp678)
                                                      (if (if tmp678
                                                              (apply
                                                                (lambda (dots680
                                                                         e679)
                                                                  (ellipsis?667
                                                                    dots680))
                                                                tmp678)
                                                              '#f)
                                                          (apply
                                                            (lambda (dots682
                                                                     e681)
                                                              (if vec?666
                                                                  (syntax-error
                                                                    src671
                                                                    '"misplaced ellipsis in syntax form")
                                                                  (gen-syntax606
                                                                    src671
                                                                    e681
                                                                    r669
                                                                    maps668
                                                                    (lambda (x683)
                                                                      '#f)
                                                                    '#f
                                                                    fm665)))
                                                            tmp678)
                                                          ((lambda (tmp684)
                                                             (if (if tmp684
                                                                     (apply
                                                                       (lambda (x687
                                                                                dots686
                                                                                y685)
                                                                         (ellipsis?667
                                                                           dots686))
                                                                       tmp684)
                                                                     '#f)
                                                                 (apply
                                                                   (lambda (x690
                                                                            dots689
                                                                            y688)
                                                                     ((letrec ([f694 (lambda (y696
                                                                                              k695)
                                                                                       ((lambda (tmp697)
                                                                                          ((lambda (tmp698)
                                                                                             (if tmp698
                                                                                                 (apply
                                                                                                   (lambda ()
                                                                                                     (k695
                                                                                                       maps668))
                                                                                                   tmp698)
                                                                                                 ((lambda (tmp699)
                                                                                                    (if (if tmp699
                                                                                                            (apply
                                                                                                              (lambda (dots701
                                                                                                                       y700)
                                                                                                                (ellipsis?667
                                                                                                                  dots701))
                                                                                                              tmp699)
                                                                                                            '#f)
                                                                                                        (apply
                                                                                                          (lambda (dots703
                                                                                                                   y702)
                                                                                                            (f694
                                                                                                              y702
                                                                                                              (lambda (maps704)
                                                                                                                (call-with-values
                                                                                                                  (lambda ()
                                                                                                                    (k695
                                                                                                                      (cons
                                                                                                                        '()
                                                                                                                        maps704)))
                                                                                                                  (lambda (x706
                                                                                                                           maps705)
                                                                                                                    (if (null?
                                                                                                                          (car maps705))
                                                                                                                        (syntax-error
                                                                                                                          src671
                                                                                                                          '"extra ellipsis in syntax form")
                                                                                                                        (values
                                                                                                                          (gen-mappend609
                                                                                                                            x706
                                                                                                                            (car maps705))
                                                                                                                          (cdr maps705))))))))
                                                                                                          tmp699)
                                                                                                        (call-with-values
                                                                                                          (lambda ()
                                                                                                            (gen-syntax606
                                                                                                              src671
                                                                                                              y696
                                                                                                              r669
                                                                                                              maps668
                                                                                                              ellipsis?667
                                                                                                              vec?666
                                                                                                              fm665))
                                                                                                          (lambda (y708
                                                                                                                   maps707)
                                                                                                            (call-with-values
                                                                                                              (lambda ()
                                                                                                                (k695
                                                                                                                  maps707))
                                                                                                              (lambda (x710
                                                                                                                       maps709)
                                                                                                                (values
                                                                                                                  (gen-append608
                                                                                                                    x710
                                                                                                                    y708)
                                                                                                                  maps709)))))))
                                                                                                   ($syntax-dispatch
                                                                                                     tmp697
                                                                                                     '(any .
                                                                                                           any)))))
                                                                                            ($syntax-dispatch
                                                                                              tmp697
                                                                                              '())))
                                                                                         y696))])
                                                                        f694)
                                                                       y688
                                                                       (lambda (maps691)
                                                                         (call-with-values
                                                                           (lambda ()
                                                                             (gen-syntax606
                                                                               src671
                                                                               x690
                                                                               r669
                                                                               (cons
                                                                                 '()
                                                                                 maps691)
                                                                               ellipsis?667
                                                                               '#f
                                                                               fm665))
                                                                           (lambda (x693
                                                                                    maps692)
                                                                             (if (null?
                                                                                   (car maps692))
                                                                                 (syntax-error
                                                                                   src671
                                                                                   '"extra ellipsis in syntax form")
                                                                                 (values
                                                                                   (gen-map610
                                                                                     x693
                                                                                     (car maps692))
                                                                                   (cdr maps692))))))))
                                                                   tmp684)
                                                                 ((lambda (tmp711)
                                                                    (if tmp711
                                                                        (apply
                                                                          (lambda (x713
                                                                                   y712)
                                                                            (call-with-values
                                                                              (lambda ()
                                                                                (gen-syntax606
                                                                                  src671
                                                                                  x713
                                                                                  r669
                                                                                  maps668
                                                                                  ellipsis?667
                                                                                  '#f
                                                                                  fm665))
                                                                              (lambda (xnew715
                                                                                       maps714)
                                                                                (call-with-values
                                                                                  (lambda ()
                                                                                    (gen-syntax606
                                                                                      src671
                                                                                      y712
                                                                                      r669
                                                                                      maps714
                                                                                      ellipsis?667
                                                                                      vec?666
                                                                                      fm665))
                                                                                  (lambda (ynew717
                                                                                           maps716)
                                                                                    (values
                                                                                      (gen-cons611
                                                                                        e670
                                                                                        x713
                                                                                        y712
                                                                                        xnew715
                                                                                        ynew717)
                                                                                      maps716))))))
                                                                          tmp711)
                                                                        ((lambda (tmp718)
                                                                           (if tmp718
                                                                               (apply
                                                                                 (lambda (x1720
                                                                                          x2719)
                                                                                   ((lambda (ls722)
                                                                                      (call-with-values
                                                                                        (lambda ()
                                                                                          (gen-syntax606
                                                                                            src671
                                                                                            ls722
                                                                                            r669
                                                                                            maps668
                                                                                            ellipsis?667
                                                                                            '#t
                                                                                            fm665))
                                                                                        (lambda (lsnew724
                                                                                                 maps723)
                                                                                          (values
                                                                                            (gen-vector612
                                                                                              e670
                                                                                              ls722
                                                                                              lsnew724)
                                                                                            maps723))))
                                                                                     (cons
                                                                                       x1720
                                                                                       x2719)))
                                                                                 tmp718)
                                                                               ((lambda (tmp725)
                                                                                  (if (if tmp725
                                                                                          (apply
                                                                                            (lambda ()
                                                                                              vec?666)
                                                                                            tmp725)
                                                                                          '#f)
                                                                                      (apply
                                                                                        (lambda ()
                                                                                          (values
                                                                                            ''()
                                                                                            maps668))
                                                                                        tmp725)
                                                                                      (values
                                                                                        (cons
                                                                                          'quote
                                                                                          (cons
                                                                                            e670
                                                                                            '()))
                                                                                        maps668)))
                                                                                 ($syntax-dispatch
                                                                                   tmp677
                                                                                   '()))))
                                                                          ($syntax-dispatch
                                                                            tmp677
                                                                            '#(vector
                                                                               (any .
                                                                                    each-any))))))
                                                                   ($syntax-dispatch
                                                                     tmp677
                                                                     '(any .
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp677
                                                              '(any any
                                                                    .
                                                                    any)))))
                                                     ($syntax-dispatch
                                                       tmp677
                                                       '(any any))))
                                                  e670)))]
                           [gen-ref607 (lambda (src659 var658 level657
                                                maps656)
                                         (if (= level657 '0)
                                             (values var658 maps656)
                                             (if (null? maps656)
                                                 (syntax-error
                                                   src659
                                                   '"missing ellipsis in syntax form")
                                                 (call-with-values
                                                   (lambda ()
                                                     (gen-ref607
                                                       src659
                                                       var658
                                                       (- level657 '1)
                                                       (cdr maps656)))
                                                   (lambda (outer-var661
                                                            outer-maps660)
                                                     ((lambda (t662)
                                                        (if t662
                                                            ((lambda (b663)
                                                               (values
                                                                 (cdr b663)
                                                                 maps656))
                                                              t662)
                                                            ((lambda (inner-var664)
                                                               (values
                                                                 inner-var664
                                                                 (cons
                                                                   (cons
                                                                     (cons
                                                                       outer-var661
                                                                       inner-var664)
                                                                     (car maps656))
                                                                   outer-maps660)))
                                                              (gen-var121
                                                                '#(syntax-object
                                                                   tmp
                                                                   (top)
                                                                   ())))))
                                                       (assq
                                                         outer-var661
                                                         (car maps656))))))))]
                           [gen-append608 (lambda (x655 y654)
                                            (if (equal? y654 ''())
                                                x655
                                                (cons
                                                  'append
                                                  (cons
                                                    x655
                                                    (cons y654 '())))))]
                           [gen-mappend609 (lambda (e653 map-env652)
                                             (cons
                                               'apply
                                               (cons
                                                 '(primitive append)
                                                 (cons
                                                   (gen-map610
                                                     e653
                                                     map-env652)
                                                   '()))))]
                           [gen-map610 (lambda (e645 map-env644)
                                         ((lambda (formals648 actuals647)
                                            (if (eq? (car e645) 'ref)
                                                (car actuals647)
                                                (if (andmap37
                                                      (lambda (x649)
                                                        (if (eq? (car x649)
                                                                 'ref)
                                                            (memq
                                                              (cadr x649)
                                                              formals648)
                                                            '#f))
                                                      (cdr e645))
                                                    (cons
                                                      'map
                                                      (cons
                                                        (cons
                                                          'primitive
                                                          (cons
                                                            (car e645)
                                                            '()))
                                                        (append
                                                          (map ((lambda (r650)
                                                                  (lambda (x651)
                                                                    (cdr (assq
                                                                           (cadr
                                                                             x651)
                                                                           r650))))
                                                                 (map cons
                                                                      formals648
                                                                      actuals647))
                                                               (cdr e645))
                                                          '())))
                                                    (cons
                                                      'map
                                                      (cons
                                                        (cons
                                                          'lambda
                                                          (cons
                                                            formals648
                                                            (cons
                                                              e645
                                                              '())))
                                                        (append
                                                          actuals647
                                                          '()))))))
                                           (map cdr map-env644)
                                           (map (lambda (x646)
                                                  (cons
                                                    'ref
                                                    (cons (car x646) '())))
                                                map-env644)))]
                           [gen-cons611 (lambda (e640 x639 y638 xnew637
                                                 ynew636)
                                          ((lambda (t641)
                                             (if (memv t641 '(quote))
                                                 (if (eq? (car xnew637)
                                                          'quote)
                                                     ((lambda (xnew643
                                                               ynew642)
                                                        (if (if (eq? xnew643
                                                                     x639)
                                                                (eq? ynew642
                                                                     y638)
                                                                '#f)
                                                            (cons
                                                              'quote
                                                              (cons
                                                                e640
                                                                '()))
                                                            (cons
                                                              'quote
                                                              (cons
                                                                (cons
                                                                  xnew643
                                                                  ynew642)
                                                                '()))))
                                                       (cadr xnew637)
                                                       (cadr ynew636))
                                                     (if (eq? (cadr
                                                                ynew636)
                                                              '())
                                                         (cons
                                                           'list
                                                           (cons
                                                             xnew637
                                                             '()))
                                                         (cons
                                                           'cons
                                                           (cons
                                                             xnew637
                                                             (cons
                                                               ynew636
                                                               '())))))
                                                 (if (memv t641 '(list))
                                                     (cons
                                                       'list
                                                       (cons
                                                         xnew637
                                                         (append
                                                           (cdr ynew636)
                                                           '())))
                                                     (cons
                                                       'cons
                                                       (cons
                                                         xnew637
                                                         (cons
                                                           ynew636
                                                           '()))))))
                                            (car ynew636)))]
                           [gen-vector612 (lambda (e635 ls634 lsnew633)
                                            (if (eq? (car lsnew633) 'quote)
                                                (if (eq? (cadr lsnew633)
                                                         ls634)
                                                    (cons
                                                      'quote
                                                      (cons e635 '()))
                                                    (cons
                                                      'quote
                                                      (cons
                                                        (list->vector
                                                          (cadr lsnew633))
                                                        '())))
                                                (if (eq? (car lsnew633)
                                                         'list)
                                                    (cons
                                                      'vector
                                                      (append
                                                        (cdr lsnew633)
                                                        '()))
                                                    (cons
                                                      'list->vector
                                                      (cons
                                                        lsnew633
                                                        '())))))]
                           [regen613 (lambda (x630)
                                       ((lambda (t631)
                                          (if (memv t631 '(ref))
                                              (build-lexical-reference26
                                                no-source3
                                                (cadr x630))
                                              (if (memv t631 '(primitive))
                                                  (build-primref30
                                                    no-source3
                                                    (cadr x630))
                                                  (if (memv t631 '(quote))
                                                      (build-data31
                                                        no-source3
                                                        (cadr x630))
                                                      (if (memv
                                                            t631
                                                            '(lambda))
                                                          (build-lambda29
                                                            no-source3
                                                            (cadr x630)
                                                            '#f
                                                            (regen613
                                                              (caddr
                                                                x630)))
                                                          (if (memv
                                                                t631
                                                                '(map))
                                                              ((lambda (ls632)
                                                                 (build-application11
                                                                   no-source3
                                                                   (build-primref30
                                                                     no-source3
                                                                     'map)
                                                                   ls632))
                                                                (map regen613
                                                                     (cdr x630)))
                                                              (build-application11
                                                                no-source3
                                                                (build-primref30
                                                                  no-source3
                                                                  (car x630))
                                                                (map regen613
                                                                     (cdr x630)))))))))
                                         (car x630)))])
                   (begin
                     (global-extend9
                       'core
                       'syntax
                       (lambda (e624 r623 mr622)
                         ((lambda (tmp625)
                            ((lambda (tmp626)
                               (if tmp626
                                   (apply
                                     (lambda (x627)
                                       (call-with-values
                                         (lambda ()
                                           (gen-syntax606 e624 x627 r623
                                             '() ellipsis?605 '#f '#f))
                                         (lambda (e629 maps628)
                                           (regen613 e629))))
                                     tmp626)
                                   (syntax-error tmp625)))
                              ($syntax-dispatch tmp625 '(_ any))))
                           e624)))
                     (global-extend9
                       'core
                       'fresh-syntax
                       (lambda (e616 r615 mr614)
                         ((lambda (tmp617)
                            ((lambda (tmp618)
                               (if tmp618
                                   (apply
                                     (lambda (x619)
                                       (call-with-values
                                         (lambda ()
                                           (gen-syntax606 e616 x619 r615
                                             '() ellipsis?605 '#f
                                             (gen-mark90)))
                                         (lambda (e621 maps620)
                                           (regen613 e621))))
                                     tmp618)
                                   (syntax-error tmp617)))
                              ($syntax-dispatch tmp617 '(_ any))))
                           e616)))))))))))
       (set! $syntax-dispatch
         (lambda (e533 p532)
           (letrec* ([match-each534 (lambda (e590 p589 m*588 s*587)
                                      (if (pair? e590)
                                          ((lambda (first591)
                                             (if first591
                                                 ((lambda (rest592)
                                                    (if rest592
                                                        (cons
                                                          first591
                                                          rest592)
                                                        '#f))
                                                   (match-each534
                                                     (cdr e590)
                                                     p589
                                                     m*588
                                                     s*587))
                                                 '#f))
                                            (match540 (car e590) p589 m*588
                                              s*587 '()))
                                          (if (null? e590)
                                              '()
                                              (if (syntax-object?78 e590)
                                                  (call-with-values
                                                    (lambda ()
                                                      (join-wraps96
                                                        m*588
                                                        s*587
                                                        e590))
                                                    (lambda (m*594 s*593)
                                                      (match-each534
                                                        (syntax-object-expression79
                                                          e590)
                                                        p589
                                                        m*594
                                                        s*593)))
                                                  (if (annotation?4 e590)
                                                      (match-each534
                                                        (annotation-expression5
                                                          e590)
                                                        p589
                                                        m*588
                                                        s*587)
                                                      '#f)))))]
                     [match-each+535 (lambda (e576 x-pat575 y-pat574
                                              z-pat573 m*572 s*571 r570)
                                       ((letrec ([f577 (lambda (e580 m*579
                                                                s*578)
                                                         (if (pair? e580)
                                                             (call-with-values
                                                               (lambda ()
                                                                 (f577
                                                                   (cdr e580)
                                                                   m*579
                                                                   s*578))
                                                               (lambda (xr*583
                                                                        y-pat582
                                                                        r581)
                                                                 (if r581
                                                                     (if (null?
                                                                           y-pat582)
                                                                         ((lambda (xr584)
                                                                            (if xr584
                                                                                (values
                                                                                  (cons
                                                                                    xr584
                                                                                    xr*583)
                                                                                  y-pat582
                                                                                  r581)
                                                                                (values
                                                                                  '#f
                                                                                  '#f
                                                                                  '#f)))
                                                                           (match540
                                                                             (car e580)
                                                                             x-pat575
                                                                             m*579
                                                                             s*578
                                                                             '()))
                                                                         (values
                                                                           '()
                                                                           (cdr y-pat582)
                                                                           (match540
                                                                             (car e580)
                                                                             (car y-pat582)
                                                                             m*579
                                                                             s*578
                                                                             r581)))
                                                                     (values
                                                                       '#f
                                                                       '#f
                                                                       '#f))))
                                                             (if (syntax-object?78
                                                                   e580)
                                                                 (call-with-values
                                                                   (lambda ()
                                                                     (join-wraps96
                                                                       m*579
                                                                       s*578
                                                                       e580))
                                                                   (lambda (m*586
                                                                            s*585)
                                                                     (f577
                                                                       (syntax-object-expression79
                                                                         e580)
                                                                       m*586
                                                                       s*585)))
                                                                 (if (annotation?4
                                                                       e580)
                                                                     (f577
                                                                       (annotation-expression5
                                                                         e580)
                                                                       m*579
                                                                       s*578)
                                                                     (values
                                                                       '()
                                                                       y-pat574
                                                                       (match540
                                                                         e580
                                                                         z-pat573
                                                                         m*579
                                                                         s*578
                                                                         r570))))))])
                                          f577)
                                         e576
                                         m*572
                                         s*571))]
                     [match-each-any536 (lambda (e566 m*565 s*564)
                                          (if (pair? e566)
                                              ((lambda (l567)
                                                 (if l567
                                                     (cons
                                                       (syntax-object97
                                                         (car e566)
                                                         m*565
                                                         s*564)
                                                       l567)
                                                     '#f))
                                                (match-each-any536
                                                  (cdr e566)
                                                  m*565
                                                  s*564))
                                              (if (null? e566)
                                                  '()
                                                  (if (syntax-object?78
                                                        e566)
                                                      (call-with-values
                                                        (lambda ()
                                                          (join-wraps96
                                                            m*565
                                                            s*564
                                                            e566))
                                                        (lambda (m*569
                                                                 s*568)
                                                          (match-each-any536
                                                            (syntax-object-expression79
                                                              e566)
                                                            m*569
                                                            s*568)))
                                                      (if (annotation?4
                                                            e566)
                                                          (match-each-any536
                                                            (annotation-expression5
                                                              e566)
                                                            m*565
                                                            s*564)
                                                          '#f)))))]
                     [match-empty537 (lambda (p562 r561)
                                       (if (null? p562)
                                           r561
                                           (if (eq? p562 '_)
                                               r561
                                               (if (eq? p562 'any)
                                                   (cons '() r561)
                                                   (if (pair? p562)
                                                       (match-empty537
                                                         (car p562)
                                                         (match-empty537
                                                           (cdr p562)
                                                           r561))
                                                       (if (eq? p562
                                                                'each-any)
                                                           (cons '() r561)
                                                           ((lambda (t563)
                                                              (if (memv
                                                                    t563
                                                                    '(each))
                                                                  (match-empty537
                                                                    (vector-ref
                                                                      p562
                                                                      '1)
                                                                    r561)
                                                                  (if (memv
                                                                        t563
                                                                        '(each+))
                                                                      (match-empty537
                                                                        (vector-ref
                                                                          p562
                                                                          '1)
                                                                        (match-empty537
                                                                          (reverse
                                                                            (vector-ref
                                                                              p562
                                                                              '2))
                                                                          (match-empty537
                                                                            (vector-ref
                                                                              p562
                                                                              '3)
                                                                            r561)))
                                                                      (if (memv
                                                                            t563
                                                                            '(free-id
                                                                               atom))
                                                                          r561
                                                                          (if (memv
                                                                                t563
                                                                                '(vector))
                                                                              (match-empty537
                                                                                (vector-ref
                                                                                  p562
                                                                                  '1)
                                                                                r561)
                                                                              (error-hook1
                                                                                '$syntax-dispatch
                                                                                '"invalid pattern"
                                                                                p562))))))
                                                             (vector-ref
                                                               p562
                                                               '0))))))))]
                     [combine538 (lambda (r*560 r559)
                                   (if (null? (car r*560))
                                       r559
                                       (cons
                                         (map car r*560)
                                         (combine538
                                           (map cdr r*560)
                                           r559))))]
                     [match*539 (lambda (e552 p551 m*550 s*549 r548)
                                  (if (null? p551)
                                      (if (null? e552) r548 '#f)
                                      (if (pair? p551)
                                          (if (pair? e552)
                                              (match540 (car e552)
                                                (car p551) m*550 s*549
                                                (match540 (cdr e552)
                                                  (cdr p551) m*550 s*549
                                                  r548))
                                              '#f)
                                          (if (eq? p551 'each-any)
                                              ((lambda (l553)
                                                 (if l553
                                                     (cons l553 r548)
                                                     '#f))
                                                (match-each-any536
                                                  e552
                                                  m*550
                                                  s*549))
                                              ((lambda (t554)
                                                 (if (memv t554 '(each))
                                                     (if (null? e552)
                                                         (match-empty537
                                                           (vector-ref
                                                             p551
                                                             '1)
                                                           r548)
                                                         ((lambda (r*555)
                                                            (if r*555
                                                                (combine538
                                                                  r*555
                                                                  r548)
                                                                '#f))
                                                           (match-each534
                                                             e552
                                                             (vector-ref
                                                               p551
                                                               '1)
                                                             m*550
                                                             s*549)))
                                                     (if (memv
                                                           t554
                                                           '(free-id))
                                                         (if (symbol? e552)
                                                             (if (free-id=?124
                                                                   (syntax-object97
                                                                     e552
                                                                     m*550
                                                                     s*549)
                                                                   (vector-ref
                                                                     p551
                                                                     '1))
                                                                 r548
                                                                 '#f)
                                                             '#f)
                                                         (if (memv
                                                               t554
                                                               '(each+))
                                                             (call-with-values
                                                               (lambda ()
                                                                 (match-each+535
                                                                   e552
                                                                   (vector-ref
                                                                     p551
                                                                     '1)
                                                                   (vector-ref
                                                                     p551
                                                                     '2)
                                                                   (vector-ref
                                                                     p551
                                                                     '3)
                                                                   m*550
                                                                   s*549
                                                                   r548))
                                                               (lambda (xr*558
                                                                        y-pat557
                                                                        r556)
                                                                 (if r556
                                                                     (if (null?
                                                                           y-pat557)
                                                                         (if (null?
                                                                               xr*558)
                                                                             (match-empty537
                                                                               (vector-ref
                                                                                 p551
                                                                                 '1)
                                                                               r556)
                                                                             (combine538
                                                                               xr*558
                                                                               r556))
                                                                         '#f)
                                                                     '#f)))
                                                             (if (memv
                                                                   t554
                                                                   '(atom))
                                                                 (if (equal?
                                                                       (vector-ref
                                                                         p551
                                                                         '1)
                                                                       (strip85
                                                                         e552
                                                                         m*550))
                                                                     r548
                                                                     '#f)
                                                                 (if (memv
                                                                       t554
                                                                       '(vector))
                                                                     (if (vector?
                                                                           e552)
                                                                         (match540
                                                                           (vector->list
                                                                             e552)
                                                                           (vector-ref
                                                                             p551
                                                                             '1)
                                                                           m*550
                                                                           s*549
                                                                           r548)
                                                                         '#f)
                                                                     (error-hook1
                                                                       '$syntax-dispatch
                                                                       '"invalid pattern"
                                                                       p551)))))))
                                                (vector-ref p551 '0))))))]
                     [match540 (lambda (e545 p544 m*543 s*542 r541)
                                 (if (not r541)
                                     '#f
                                     (if (eq? p544 '_)
                                         r541
                                         (if (eq? p544 'any)
                                             (cons
                                               (syntax-object97
                                                 e545
                                                 m*543
                                                 s*542)
                                               r541)
                                             (if (syntax-object?78 e545)
                                                 (call-with-values
                                                   (lambda ()
                                                     (join-wraps96
                                                       m*543
                                                       s*542
                                                       e545))
                                                   (lambda (m*547 s*546)
                                                     (match540
                                                       (syntax-object-expression79
                                                         e545)
                                                       p544 m*547 s*546
                                                       r541)))
                                                 (match*539
                                                   (unannotate87 e545) p544
                                                   m*543 s*542 r541))))))])
             (match540 e533 p532 '() '() '()))))
       ((lambda ()
          (letrec* ([arg-check513 (lambda (pred?531 x530 who529)
                                    (if (not (pred?531 x530))
                                        (error-hook1
                                          who529
                                          '"invalid argument"
                                          x530)
                                        (void)))])
            (begin
              (set! identifier? (lambda (x528) (id?119 x528)))
              (set! datum->syntax
                (lambda (id527 datum526)
                  (begin
                    (arg-check513 id?119 id527 'datum->syntax)
                    (make-syntax-object77
                      datum526
                      (syntax-object-mark*80 id527)
                      (syntax-object-subst*81 id527)))))
              (set! syntax->datum (lambda (x525) (strip85 x525 '())))
              (set! generate-temporaries
                (lambda (ls523)
                  (begin
                    (arg-check513 list? ls523 'generate-temporaries)
                    (map (lambda (x524)
                           (make-syntax-object77
                             (gensym-hook2)
                             top-mark*88
                             top-subst*94))
                         ls523))))
              (set! free-identifier=?
                (lambda (x522 y521)
                  (begin
                    (arg-check513 id?119 x522 'free-identifier=?)
                    (arg-check513 id?119 y521 'free-identifier=?)
                    (free-id=?124 x522 y521))))
              (set! bound-identifier=?
                (lambda (x520 y519)
                  (begin
                    (arg-check513 id?119 x520 'bound-identifier=?)
                    (arg-check513 id?119 y519 'bound-identifier=?)
                    (bound-id=?125 x520 y519))))
              (set! syntax-error
                (lambda (object516 . messages515)
                  (begin
                    (for-each
                      (lambda (x518)
                        (arg-check513 string? x518 'syntax-error))
                      messages515)
                    ((lambda (message517)
                       (error-hook1
                         '#f
                         message517
                         (strip85 object516 '())))
                      (if (null? messages515)
                          '"invalid syntax"
                          (apply string-append messages515))))))
              (set! make-variable-transformer
                (lambda (p514)
                  (begin
                    (arg-check513
                      procedure?
                      p514
                      'make-variable-transformer)
                    (cons 'macro! p514))))))))
       (global-extend9
         'macro
         'with-syntax
         (lambda (x493)
           ((lambda (tmp494)
              ((lambda (tmp495)
                 (if tmp495
                     (apply
                       (lambda (e1497 e2496)
                         (cons
                           '#(syntax-object begin (top) ())
                           (cons e1497 e2496)))
                       tmp495)
                     ((lambda (tmp499)
                        (if tmp499
                            (apply
                              (lambda (out503 in502 e1501 e2500)
                                (cons
                                  '#(syntax-object syntax-case (top) ())
                                  (cons
                                    in502
                                    (cons
                                      '#(syntax-object () (top) ())
                                      (cons
                                        (cons
                                          out503
                                          (cons
                                            (cons
                                              '#(syntax-object begin (top)
                                                 ())
                                              (cons e1501 e2500))
                                            '#(syntax-object () (top) ())))
                                        '#(syntax-object () (top) ()))))))
                              tmp499)
                            ((lambda (tmp505)
                               (if tmp505
                                   (apply
                                     (lambda (out509 in508 e1507 e2506)
                                       (cons
                                         '#(syntax-object syntax-case (top)
                                            ())
                                         (cons
                                           (cons
                                             '#(syntax-object list (top)
                                                ())
                                             in508)
                                           (cons
                                             '#(syntax-object () (top) ())
                                             (cons
                                               (cons
                                                 out509
                                                 (cons
                                                   (cons
                                                     '#(syntax-object begin
                                                        (top) ())
                                                     (cons e1507 e2506))
                                                   '#(syntax-object ()
                                                      (top) ())))
                                               '#(syntax-object () (top)
                                                  ()))))))
                                     tmp505)
                                   (syntax-error tmp494)))
                              ($syntax-dispatch
                                tmp494
                                '(_ #(each (any any)) any . each-any)))))
                       ($syntax-dispatch
                         tmp494
                         '(_ ((any any)) any . each-any)))))
                ($syntax-dispatch tmp494 '(_ () any . each-any))))
             x493)))
       (global-extend9
         'macro
         'syntax-rules
         (lambda (x467)
           (letrec* ([clause468 (lambda (y482)
                                  ((lambda (tmp483)
                                     ((lambda (tmp484)
                                        (if tmp484
                                            (apply
                                              (lambda (keyword487
                                                       pattern486
                                                       template485)
                                                (cons
                                                  (cons
                                                    '#(syntax-object dummy
                                                       (top) ())
                                                    pattern486)
                                                  (cons
                                                    (cons
                                                      '#(syntax-object
                                                         syntax (top) ())
                                                      (cons
                                                        template485
                                                        '#(syntax-object ()
                                                           (top) ())))
                                                    '#(syntax-object ()
                                                       (top) ()))))
                                              tmp484)
                                            ((lambda (tmp488)
                                               (if tmp488
                                                   (apply
                                                     (lambda (keyword492
                                                              pattern491
                                                              fender490
                                                              template489)
                                                       (cons
                                                         (cons
                                                           '#(syntax-object
                                                              dummy (top)
                                                              ())
                                                           pattern491)
                                                         (cons
                                                           fender490
                                                           (cons
                                                             (cons
                                                               '#(syntax-object
                                                                  syntax
                                                                  (top) ())
                                                               (cons
                                                                 template489
                                                                 '#(syntax-object
                                                                    ()
                                                                    (top)
                                                                    ())))
                                                             '#(syntax-object
                                                                () (top)
                                                                ())))))
                                                     tmp488)
                                                   (syntax-error x467)))
                                              ($syntax-dispatch
                                                tmp483
                                                '((any . any) any any)))))
                                       ($syntax-dispatch
                                         tmp483
                                         '((any . any) any))))
                                    y482))])
             ((lambda (tmp469)
                ((lambda (tmp470)
                   (if (if tmp470
                           (apply
                             (lambda (k472 cl471)
                               (andmap37 identifier? k472))
                             tmp470)
                           '#f)
                       (apply
                         (lambda (k475 cl474)
                           ((lambda (tmp476)
                              ((lambda (tmp478)
                                 (if tmp478
                                     (apply
                                       (lambda (cl479)
                                         (cons
                                           '#(syntax-object lambda (top)
                                              ())
                                           (cons
                                             '#(syntax-object (x) (top) ())
                                             (cons
                                               (cons
                                                 '#(syntax-object
                                                    syntax-case (top) ())
                                                 (cons
                                                   '#(syntax-object x (top)
                                                      ())
                                                   (cons k475 cl479)))
                                               '#(syntax-object () (top)
                                                  ())))))
                                       tmp478)
                                     (syntax-error tmp476)))
                                ($syntax-dispatch tmp476 'each-any)))
                             (map clause468 cl474)))
                         tmp470)
                       (syntax-error tmp469)))
                  ($syntax-dispatch tmp469 '(_ each-any . each-any))))
               x467))))
       (global-extend9
         'macro
         'or
         (lambda (x457)
           ((lambda (tmp458)
              ((lambda (tmp459)
                 (if tmp459
                     (apply
                       (lambda () '#(syntax-object #f (top) ()))
                       tmp459)
                     ((lambda (tmp460)
                        (if tmp460
                            (apply (lambda (e461) e461) tmp460)
                            ((lambda (tmp462)
                               (if tmp462
                                   (apply
                                     (lambda (e1465 e2464 e3463)
                                       (cons
                                         '#(syntax-object let (top) ())
                                         (cons
                                           (cons
                                             (cons
                                               '#(syntax-object t (top) ())
                                               (cons
                                                 e1465
                                                 '#(syntax-object () (top)
                                                    ())))
                                             '#(syntax-object () (top) ()))
                                           (cons
                                             (cons
                                               '#(syntax-object if (top)
                                                  ())
                                               (cons
                                                 '#(syntax-object t (top)
                                                    ())
                                                 (cons
                                                   '#(syntax-object t (top)
                                                      ())
                                                   (cons
                                                     (cons
                                                       '#(syntax-object or
                                                          (top) ())
                                                       (cons e2464 e3463))
                                                     '#(syntax-object ()
                                                        (top) ())))))
                                             '#(syntax-object () (top)
                                                ())))))
                                     tmp462)
                                   (syntax-error tmp458)))
                              ($syntax-dispatch
                                tmp458
                                '(_ any any . each-any)))))
                       ($syntax-dispatch tmp458 '(_ any)))))
                ($syntax-dispatch tmp458 '(_))))
             x457)))
       (global-extend9
         'macro
         'and
         (lambda (x447)
           ((lambda (tmp448)
              ((lambda (tmp449)
                 (if tmp449
                     (apply
                       (lambda (e1452 e2451 e3450)
                         (cons
                           '#(syntax-object if (top) ())
                           (cons
                             e1452
                             (cons
                               (cons
                                 '#(syntax-object and (top) ())
                                 (cons e2451 e3450))
                               '#(syntax-object (#f) (top) ())))))
                       tmp449)
                     ((lambda (tmp454)
                        (if tmp454
                            (apply (lambda (e455) e455) tmp454)
                            ((lambda (tmp456)
                               (if tmp456
                                   (apply
                                     (lambda ()
                                       '#(syntax-object #t (top) ()))
                                     tmp456)
                                   (syntax-error tmp448)))
                              ($syntax-dispatch tmp448 '(_)))))
                       ($syntax-dispatch tmp448 '(_ any)))))
                ($syntax-dispatch tmp448 '(_ any any . each-any))))
             x447)))
       (global-extend9
         'macro
         'let
         (lambda (x417)
           ((lambda (tmp418)
              ((lambda (tmp419)
                 (if (if tmp419
                         (apply
                           (lambda (x423 v422 e1421 e2420)
                             (andmap37 identifier? x423))
                           tmp419)
                         '#f)
                     (apply
                       (lambda (x428 v427 e1426 e2425)
                         (cons
                           (cons
                             '#(syntax-object lambda (top) ())
                             (cons x428 (cons e1426 e2425)))
                           v427))
                       tmp419)
                     ((lambda (tmp432)
                        (if (if tmp432
                                (apply
                                  (lambda (f437 x436 v435 e1434 e2433)
                                    (andmap37
                                      identifier?
                                      (cons f437 x436)))
                                  tmp432)
                                '#f)
                            (apply
                              (lambda (f443 x442 v441 e1440 e2439)
                                (cons
                                  (cons
                                    '#(syntax-object letrec (top) ())
                                    (cons
                                      (cons
                                        (cons
                                          f443
                                          (cons
                                            (cons
                                              '#(syntax-object lambda (top)
                                                 ())
                                              (cons
                                                x442
                                                (cons e1440 e2439)))
                                            '#(syntax-object () (top) ())))
                                        '#(syntax-object () (top) ()))
                                      (cons
                                        f443
                                        '#(syntax-object () (top) ()))))
                                  v441))
                              tmp432)
                            (syntax-error tmp418)))
                       ($syntax-dispatch
                         tmp418
                         '(_ any #(each (any any)) any . each-any)))))
                ($syntax-dispatch
                  tmp418
                  '(_ #(each (any any)) any . each-any))))
             x417)))
       (global-extend9
         'macro
         'let*
         (lambda (x386)
           ((lambda (tmp387)
              ((lambda (tmp388)
                 (if tmp388
                     (apply
                       (lambda (e1390 e2389)
                         (cons
                           '#(syntax-object let (top) ())
                           (cons
                             '#(syntax-object () (top) ())
                             (cons e1390 e2389))))
                       tmp388)
                     ((lambda (tmp392)
                        (if (if tmp392
                                (apply
                                  (lambda (x396 v395 e1394 e2393)
                                    (andmap37 identifier? x396))
                                  tmp392)
                                '#f)
                            (apply
                              (lambda (x401 v400 e1399 e2398)
                                ((letrec ([f404 (lambda (bindings405)
                                                  ((lambda (tmp406)
                                                     ((lambda (tmp407)
                                                        (if tmp407
                                                            (apply
                                                              (lambda (x409
                                                                       v408)
                                                                (cons
                                                                  '#(syntax-object
                                                                     let
                                                                     (top)
                                                                     ())
                                                                  (cons
                                                                    (cons
                                                                      (cons
                                                                        x409
                                                                        (cons
                                                                          v408
                                                                          '#(syntax-object
                                                                             ()
                                                                             (top)
                                                                             ())))
                                                                      '#(syntax-object
                                                                         ()
                                                                         (top)
                                                                         ()))
                                                                    (cons
                                                                      e1399
                                                                      e2398))))
                                                              tmp407)
                                                            ((lambda (tmp411)
                                                               (if tmp411
                                                                   (apply
                                                                     (lambda (x414
                                                                              v413
                                                                              rest412)
                                                                       ((lambda (tmp415)
                                                                          ((lambda (body416)
                                                                             (cons
                                                                               '#(syntax-object
                                                                                  let
                                                                                  (top)
                                                                                  ())
                                                                               (cons
                                                                                 (cons
                                                                                   (cons
                                                                                     x414
                                                                                     (cons
                                                                                       v413
                                                                                       '#(syntax-object
                                                                                          ()
                                                                                          (top)
                                                                                          ())))
                                                                                   '#(syntax-object
                                                                                      ()
                                                                                      (top)
                                                                                      ()))
                                                                                 (cons
                                                                                   body416
                                                                                   '#(syntax-object
                                                                                      ()
                                                                                      (top)
                                                                                      ())))))
                                                                            tmp415))
                                                                         (f404
                                                                           rest412)))
                                                                     tmp411)
                                                                   (syntax-error
                                                                     tmp406)))
                                                              ($syntax-dispatch
                                                                tmp406
                                                                '((any any)
                                                                   .
                                                                   any)))))
                                                       ($syntax-dispatch
                                                         tmp406
                                                         '((any any)))))
                                                    bindings405))])
                                   f404)
                                  (map (lambda (tmp403 tmp402)
                                         (cons
                                           tmp402
                                           (cons
                                             tmp403
                                             '#(syntax-object () (top)
                                                ()))))
                                       v400
                                       x401)))
                              tmp392)
                            (syntax-error tmp387)))
                       ($syntax-dispatch
                         tmp387
                         '(_ #(each (any any)) any . each-any)))))
                ($syntax-dispatch tmp387 '(_ () any . each-any))))
             x386)))
       (global-extend9
         'macro
         'cond
         (lambda (x343)
           ((lambda (tmp344)
              ((lambda (tmp345)
                 (if tmp345
                     (apply
                       (lambda (c1347 c2346)
                         ((letrec ([f349 (lambda (c1351 c2*350)
                                           ((lambda (tmp352)
                                              ((lambda (tmp353)
                                                 (if tmp353
                                                     (apply
                                                       (lambda ()
                                                         ((lambda (tmp354)
                                                            ((lambda (tmp355)
                                                               (if tmp355
                                                                   (apply
                                                                     (lambda (e1357
                                                                              e2356)
                                                                       (cons
                                                                         '#(syntax-object
                                                                            begin
                                                                            (top)
                                                                            ())
                                                                         (cons
                                                                           e1357
                                                                           e2356)))
                                                                     tmp355)
                                                                   ((lambda (tmp359)
                                                                      (if tmp359
                                                                          (apply
                                                                            (lambda (e0360)
                                                                              (cons
                                                                                '#(syntax-object
                                                                                   let
                                                                                   (top)
                                                                                   ())
                                                                                (cons
                                                                                  (cons
                                                                                    (cons
                                                                                      '#(syntax-object
                                                                                         t
                                                                                         (top)
                                                                                         ())
                                                                                      (cons
                                                                                        e0360
                                                                                        '#(syntax-object
                                                                                           ()
                                                                                           (top)
                                                                                           ())))
                                                                                    '#(syntax-object
                                                                                       ()
                                                                                       (top)
                                                                                       ()))
                                                                                  '#(syntax-object
                                                                                     ((if t
                                                                                          t))
                                                                                     (top)
                                                                                     ()))))
                                                                            tmp359)
                                                                          ((lambda (tmp361)
                                                                             (if tmp361
                                                                                 (apply
                                                                                   (lambda (e0363
                                                                                            e1362)
                                                                                     (cons
                                                                                       '#(syntax-object
                                                                                          let
                                                                                          (top)
                                                                                          ())
                                                                                       (cons
                                                                                         (cons
                                                                                           (cons
                                                                                             '#(syntax-object
                                                                                                t
                                                                                                (top)
                                                                                                ())
                                                                                             (cons
                                                                                               e0363
                                                                                               '#(syntax-object
                                                                                                  ()
                                                                                                  (top)
                                                                                                  ())))
                                                                                           '#(syntax-object
                                                                                              ()
                                                                                              (top)
                                                                                              ()))
                                                                                         (cons
                                                                                           (cons
                                                                                             '#(syntax-object
                                                                                                if
                                                                                                (top)
                                                                                                ())
                                                                                             (cons
                                                                                               '#(syntax-object
                                                                                                  t
                                                                                                  (top)
                                                                                                  ())
                                                                                               (cons
                                                                                                 (cons
                                                                                                   e1362
                                                                                                   '#(syntax-object
                                                                                                      (t)
                                                                                                      (top)
                                                                                                      ()))
                                                                                                 '#(syntax-object
                                                                                                    ()
                                                                                                    (top)
                                                                                                    ()))))
                                                                                           '#(syntax-object
                                                                                              ()
                                                                                              (top)
                                                                                              ())))))
                                                                                   tmp361)
                                                                                 ((lambda (tmp364)
                                                                                    (if tmp364
                                                                                        (apply
                                                                                          (lambda (e0367
                                                                                                   e1366
                                                                                                   e2365)
                                                                                            (cons
                                                                                              '#(syntax-object
                                                                                                 if
                                                                                                 (top)
                                                                                                 ())
                                                                                              (cons
                                                                                                e0367
                                                                                                (cons
                                                                                                  (cons
                                                                                                    '#(syntax-object
                                                                                                       begin
                                                                                                       (top)
                                                                                                       ())
                                                                                                    (cons
                                                                                                      e1366
                                                                                                      e2365))
                                                                                                  '#(syntax-object
                                                                                                     ()
                                                                                                     (top)
                                                                                                     ())))))
                                                                                          tmp364)
                                                                                        (syntax-error
                                                                                          x343)))
                                                                                   ($syntax-dispatch
                                                                                     tmp354
                                                                                     '(any any
                                                                                           .
                                                                                           each-any)))))
                                                                            ($syntax-dispatch
                                                                              tmp354
                                                                              '(any #(free-id
                                                                                      #(syntax-object
                                                                                        =>
                                                                                        (top)
                                                                                        (#(rib
                                                                                           ()
                                                                                           ()
                                                                                           ())
                                                                                          #(rib
                                                                                            (c1 c2*)
                                                                                            ((top)
                                                                                              (top))
                                                                                            ("i" "i"))
                                                                                          #(rib
                                                                                            (f)
                                                                                            ((top))
                                                                                            ("i"))
                                                                                          #(rib
                                                                                            (c1 c2)
                                                                                            ((top)
                                                                                              (top))
                                                                                            ("i" "i"))
                                                                                          #(rib
                                                                                            ()
                                                                                            ()
                                                                                            ())
                                                                                          #(rib
                                                                                            (x)
                                                                                            ((top))
                                                                                            ("i"))
                                                                                          #(rib
                                                                                            (invalid-ids-error
                                                                                             distinct-bound-ids?
                                                                                             valid-bound-ids?
                                                                                             bound-id-member?
                                                                                             bound-id=?
                                                                                             free-id=?
                                                                                             label->binding
                                                                                             id->label
                                                                                             gen-var
                                                                                             id->sym
                                                                                             id?
                                                                                             eval-transformer
                                                                                             displaced-lexical-error
                                                                                             extend-var-env*
                                                                                             extend-env*
                                                                                             extend-env
                                                                                             null-env
                                                                                             binding-value
                                                                                             binding-type
                                                                                             make-binding
                                                                                             gen-label
                                                                                             make-full-rib
                                                                                             extend-rib!
                                                                                             make-empty-rib
                                                                                             set-rib-label*!
                                                                                             set-rib-mark**!
                                                                                             set-rib-sym*!
                                                                                             rib-label*
                                                                                             rib-mark**
                                                                                             rib-sym*
                                                                                             rib?
                                                                                             make-rib
                                                                                             syntax-object
                                                                                             join-wraps
                                                                                             add-subst
                                                                                             top-subst*
                                                                                             same-marks?
                                                                                             add-mark
                                                                                             anti-mark
                                                                                             gen-mark
                                                                                             top-marked?
                                                                                             top-mark*
                                                                                             unannotate
                                                                                             source
                                                                                             strip
                                                                                             set-syntax-object-subst*!
                                                                                             set-syntax-object-mark*!
                                                                                             set-syntax-object-expression!
                                                                                             syntax-object-subst*
                                                                                             syntax-object-mark*
                                                                                             syntax-object-expression
                                                                                             syntax-object?
                                                                                             make-syntax-object
                                                                                             let-values
                                                                                             define-structure
                                                                                             andmap
                                                                                             self-evaluating?
                                                                                             build-lexical-var
                                                                                             build-letrec*
                                                                                             build-letrec
                                                                                             build-sequence
                                                                                             build-data
                                                                                             build-primref
                                                                                             build-lambda
                                                                                             build-global-assignment
                                                                                             build-lexical-assignment
                                                                                             build-lexical-reference
                                                                                             build-global-reference
                                                                                             build-conditional
                                                                                             build-application
                                                                                             global-lookup
                                                                                             global-extend
                                                                                             globals
                                                                                             strip-annotation
                                                                                             annotation-source
                                                                                             annotation-expression
                                                                                             annotation?
                                                                                             no-source
                                                                                             gensym-hook
                                                                                             error-hook
                                                                                             eval-hook)
                                                                                            ((top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top))
                                                                                            ("i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i"
                                                                                             "i")))))
                                                                                    any)))))
                                                                     ($syntax-dispatch
                                                                       tmp354
                                                                       '(any)))))
                                                              ($syntax-dispatch
                                                                tmp354
                                                                '(#(free-id
                                                                    #(syntax-object
                                                                      else
                                                                      (top)
                                                                      (#(rib
                                                                         ()
                                                                         ()
                                                                         ())
                                                                        #(rib
                                                                          (c1 c2*)
                                                                          ((top)
                                                                            (top))
                                                                          ("i" "i"))
                                                                        #(rib
                                                                          (f)
                                                                          ((top))
                                                                          ("i"))
                                                                        #(rib
                                                                          (c1 c2)
                                                                          ((top)
                                                                            (top))
                                                                          ("i" "i"))
                                                                        #(rib
                                                                          ()
                                                                          ()
                                                                          ())
                                                                        #(rib
                                                                          (x)
                                                                          ((top))
                                                                          ("i"))
                                                                        #(rib
                                                                          (invalid-ids-error
                                                                           distinct-bound-ids?
                                                                           valid-bound-ids?
                                                                           bound-id-member?
                                                                           bound-id=?
                                                                           free-id=?
                                                                           label->binding
                                                                           id->label
                                                                           gen-var
                                                                           id->sym
                                                                           id?
                                                                           eval-transformer
                                                                           displaced-lexical-error
                                                                           extend-var-env*
                                                                           extend-env*
                                                                           extend-env
                                                                           null-env
                                                                           binding-value
                                                                           binding-type
                                                                           make-binding
                                                                           gen-label
                                                                           make-full-rib
                                                                           extend-rib!
                                                                           make-empty-rib
                                                                           set-rib-label*!
                                                                           set-rib-mark**!
                                                                           set-rib-sym*!
                                                                           rib-label*
                                                                           rib-mark**
                                                                           rib-sym*
                                                                           rib?
                                                                           make-rib
                                                                           syntax-object
                                                                           join-wraps
                                                                           add-subst
                                                                           top-subst*
                                                                           same-marks?
                                                                           add-mark
                                                                           anti-mark
                                                                           gen-mark
                                                                           top-marked?
                                                                           top-mark*
                                                                           unannotate
                                                                           source
                                                                           strip
                                                                           set-syntax-object-subst*!
                                                                           set-syntax-object-mark*!
                                                                           set-syntax-object-expression!
                                                                           syntax-object-subst*
                                                                           syntax-object-mark*
                                                                           syntax-object-expression
                                                                           syntax-object?
                                                                           make-syntax-object
                                                                           let-values
                                                                           define-structure
                                                                           andmap
                                                                           self-evaluating?
                                                                           build-lexical-var
                                                                           build-letrec*
                                                                           build-letrec
                                                                           build-sequence
                                                                           build-data
                                                                           build-primref
                                                                           build-lambda
                                                                           build-global-assignment
                                                                           build-lexical-assignment
                                                                           build-lexical-reference
                                                                           build-global-reference
                                                                           build-conditional
                                                                           build-application
                                                                           global-lookup
                                                                           global-extend
                                                                           globals
                                                                           strip-annotation
                                                                           annotation-source
                                                                           annotation-expression
                                                                           annotation?
                                                                           no-source
                                                                           gensym-hook
                                                                           error-hook
                                                                           eval-hook)
                                                                          ((top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top))
                                                                          ("i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i"
                                                                           "i")))))
                                                                   any
                                                                   .
                                                                   each-any))))
                                                           c1351))
                                                       tmp353)
                                                     ((lambda (tmp369)
                                                        (if tmp369
                                                            (apply
                                                              (lambda (c2371
                                                                       c3370)
                                                                ((lambda (tmp372)
                                                                   ((lambda (rest374)
                                                                      ((lambda (tmp375)
                                                                         ((lambda (tmp376)
                                                                            (if tmp376
                                                                                (apply
                                                                                  (lambda (e0377)
                                                                                    (cons
                                                                                      '#(syntax-object
                                                                                         let
                                                                                         (top)
                                                                                         ())
                                                                                      (cons
                                                                                        (cons
                                                                                          (cons
                                                                                            '#(syntax-object
                                                                                               t
                                                                                               (top)
                                                                                               ())
                                                                                            (cons
                                                                                              e0377
                                                                                              '#(syntax-object
                                                                                                 ()
                                                                                                 (top)
                                                                                                 ())))
                                                                                          '#(syntax-object
                                                                                             ()
                                                                                             (top)
                                                                                             ()))
                                                                                        (cons
                                                                                          (cons
                                                                                            '#(syntax-object
                                                                                               if
                                                                                               (top)
                                                                                               ())
                                                                                            (cons
                                                                                              '#(syntax-object
                                                                                                 t
                                                                                                 (top)
                                                                                                 ())
                                                                                              (cons
                                                                                                '#(syntax-object
                                                                                                   t
                                                                                                   (top)
                                                                                                   ())
                                                                                                (cons
                                                                                                  rest374
                                                                                                  '#(syntax-object
                                                                                                     ()
                                                                                                     (top)
                                                                                                     ())))))
                                                                                          '#(syntax-object
                                                                                             ()
                                                                                             (top)
                                                                                             ())))))
                                                                                  tmp376)
                                                                                ((lambda (tmp378)
                                                                                   (if tmp378
                                                                                       (apply
                                                                                         (lambda (e0380
                                                                                                  e1379)
                                                                                           (cons
                                                                                             '#(syntax-object
                                                                                                let
                                                                                                (top)
                                                                                                ())
                                                                                             (cons
                                                                                               (cons
                                                                                                 (cons
                                                                                                   '#(syntax-object
                                                                                                      t
                                                                                                      (top)
                                                                                                      ())
                                                                                                   (cons
                                                                                                     e0380
                                                                                                     '#(syntax-object
                                                                                                        ()
                                                                                                        (top)
                                                                                                        ())))
                                                                                                 '#(syntax-object
                                                                                                    ()
                                                                                                    (top)
                                                                                                    ()))
                                                                                               (cons
                                                                                                 (cons
                                                                                                   '#(syntax-object
                                                                                                      if
                                                                                                      (top)
                                                                                                      ())
                                                                                                   (cons
                                                                                                     '#(syntax-object
                                                                                                        t
                                                                                                        (top)
                                                                                                        ())
                                                                                                     (cons
                                                                                                       (cons
                                                                                                         e1379
                                                                                                         '#(syntax-object
                                                                                                            (t)
                                                                                                            (top)
                                                                                                            ()))
                                                                                                       (cons
                                                                                                         rest374
                                                                                                         '#(syntax-object
                                                                                                            ()
                                                                                                            (top)
                                                                                                            ())))))
                                                                                                 '#(syntax-object
                                                                                                    ()
                                                                                                    (top)
                                                                                                    ())))))
                                                                                         tmp378)
                                                                                       ((lambda (tmp381)
                                                                                          (if tmp381
                                                                                              (apply
                                                                                                (lambda (e0384
                                                                                                         e1383
                                                                                                         e2382)
                                                                                                  (cons
                                                                                                    '#(syntax-object
                                                                                                       if
                                                                                                       (top)
                                                                                                       ())
                                                                                                    (cons
                                                                                                      e0384
                                                                                                      (cons
                                                                                                        (cons
                                                                                                          '#(syntax-object
                                                                                                             begin
                                                                                                             (top)
                                                                                                             ())
                                                                                                          (cons
                                                                                                            e1383
                                                                                                            e2382))
                                                                                                        (cons
                                                                                                          rest374
                                                                                                          '#(syntax-object
                                                                                                             ()
                                                                                                             (top)
                                                                                                             ()))))))
                                                                                                tmp381)
                                                                                              (syntax-error
                                                                                                x343)))
                                                                                         ($syntax-dispatch
                                                                                           tmp375
                                                                                           '(any any
                                                                                                 .
                                                                                                 each-any)))))
                                                                                  ($syntax-dispatch
                                                                                    tmp375
                                                                                    '(any #(free-id
                                                                                            #(syntax-object
                                                                                              =>
                                                                                              (top)
                                                                                              (#(rib
                                                                                                 (rest)
                                                                                                 ((top))
                                                                                                 ("i"))
                                                                                                #(rib
                                                                                                  (c2 c3)
                                                                                                  ((top)
                                                                                                    (top))
                                                                                                  ("i" "i"))
                                                                                                #(rib
                                                                                                  ()
                                                                                                  ()
                                                                                                  ())
                                                                                                #(rib
                                                                                                  (c1 c2*)
                                                                                                  ((top)
                                                                                                    (top))
                                                                                                  ("i" "i"))
                                                                                                #(rib
                                                                                                  (f)
                                                                                                  ((top))
                                                                                                  ("i"))
                                                                                                #(rib
                                                                                                  (c1 c2)
                                                                                                  ((top)
                                                                                                    (top))
                                                                                                  ("i" "i"))
                                                                                                #(rib
                                                                                                  ()
                                                                                                  ()
                                                                                                  ())
                                                                                                #(rib
                                                                                                  (x)
                                                                                                  ((top))
                                                                                                  ("i"))
                                                                                                #(rib
                                                                                                  (invalid-ids-error
                                                                                                   distinct-bound-ids?
                                                                                                   valid-bound-ids?
                                                                                                   bound-id-member?
                                                                                                   bound-id=?
                                                                                                   free-id=?
                                                                                                   label->binding
                                                                                                   id->label
                                                                                                   gen-var
                                                                                                   id->sym
                                                                                                   id?
                                                                                                   eval-transformer
                                                                                                   displaced-lexical-error
                                                                                                   extend-var-env*
                                                                                                   extend-env*
                                                                                                   extend-env
                                                                                                   null-env
                                                                                                   binding-value
                                                                                                   binding-type
                                                                                                   make-binding
                                                                                                   gen-label
                                                                                                   make-full-rib
                                                                                                   extend-rib!
                                                                                                   make-empty-rib
                                                                                                   set-rib-label*!
                                                                                                   set-rib-mark**!
                                                                                                   set-rib-sym*!
                                                                                                   rib-label*
                                                                                                   rib-mark**
                                                                                                   rib-sym*
                                                                                                   rib?
                                                                                                   make-rib
                                                                                                   syntax-object
                                                                                                   join-wraps
                                                                                                   add-subst
                                                                                                   top-subst*
                                                                                                   same-marks?
                                                                                                   add-mark
                                                                                                   anti-mark
                                                                                                   gen-mark
                                                                                                   top-marked?
                                                                                                   top-mark*
                                                                                                   unannotate
                                                                                                   source
                                                                                                   strip
                                                                                                   set-syntax-object-subst*!
                                                                                                   set-syntax-object-mark*!
                                                                                                   set-syntax-object-expression!
                                                                                                   syntax-object-subst*
                                                                                                   syntax-object-mark*
                                                                                                   syntax-object-expression
                                                                                                   syntax-object?
                                                                                                   make-syntax-object
                                                                                                   let-values
                                                                                                   define-structure
                                                                                                   andmap
                                                                                                   self-evaluating?
                                                                                                   build-lexical-var
                                                                                                   build-letrec*
                                                                                                   build-letrec
                                                                                                   build-sequence
                                                                                                   build-data
                                                                                                   build-primref
                                                                                                   build-lambda
                                                                                                   build-global-assignment
                                                                                                   build-lexical-assignment
                                                                                                   build-lexical-reference
                                                                                                   build-global-reference
                                                                                                   build-conditional
                                                                                                   build-application
                                                                                                   global-lookup
                                                                                                   global-extend
                                                                                                   globals
                                                                                                   strip-annotation
                                                                                                   annotation-source
                                                                                                   annotation-expression
                                                                                                   annotation?
                                                                                                   no-source
                                                                                                   gensym-hook
                                                                                                   error-hook
                                                                                                   eval-hook)
                                                                                                  ((top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top))
                                                                                                  ("i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i")))))
                                                                                          any)))))
                                                                           ($syntax-dispatch
                                                                             tmp375
                                                                             '(any))))
                                                                        c1351))
                                                                     tmp372))
                                                                  (f349
                                                                    c2371
                                                                    c3370)))
                                                              tmp369)
                                                            (syntax-error
                                                              tmp352)))
                                                       ($syntax-dispatch
                                                         tmp352
                                                         '(any .
                                                               each-any)))))
                                                ($syntax-dispatch
                                                  tmp352
                                                  '())))
                                             c2*350))])
                            f349)
                           c1347
                           c2346))
                       tmp345)
                     (syntax-error tmp344)))
                ($syntax-dispatch tmp344 '(_ any . each-any))))
             x343)))
       (global-extend9
         'macro
         'do
         (lambda (orig-x308)
           ((lambda (tmp309)
              ((lambda (tmp310)
                 (if tmp310
                     (apply
                       (lambda (var316 init315 step314 e0313 e1312 c311)
                         ((lambda (tmp317)
                            ((lambda (tmp326)
                               (if tmp326
                                   (apply
                                     (lambda (step327)
                                       ((lambda (tmp328)
                                          ((lambda (tmp330)
                                             (if tmp330
                                                 (apply
                                                   (lambda ()
                                                     (cons
                                                       '#(syntax-object let
                                                          (top) ())
                                                       (cons
                                                         '#(syntax-object
                                                            do (top) ())
                                                         (cons
                                                           (map (lambda (tmp332
                                                                         tmp331)
                                                                  (cons
                                                                    tmp331
                                                                    (cons
                                                                      tmp332
                                                                      '#(syntax-object
                                                                         ()
                                                                         (top)
                                                                         ()))))
                                                                init315
                                                                var316)
                                                           (cons
                                                             (cons
                                                               '#(syntax-object
                                                                  if (top)
                                                                  ())
                                                               (cons
                                                                 (cons
                                                                   '#(syntax-object
                                                                      not
                                                                      (top)
                                                                      ())
                                                                   (cons
                                                                     e0313
                                                                     '#(syntax-object
                                                                        ()
                                                                        (top)
                                                                        ())))
                                                                 (cons
                                                                   (cons
                                                                     '#(syntax-object
                                                                        begin
                                                                        (top)
                                                                        ())
                                                                     (append
                                                                       c311
                                                                       (cons
                                                                         (cons
                                                                           '#(syntax-object
                                                                              do
                                                                              (top)
                                                                              ())
                                                                           step327)
                                                                         '#(syntax-object
                                                                            ()
                                                                            (top)
                                                                            ()))))
                                                                   '#(syntax-object
                                                                      ()
                                                                      (top)
                                                                      ()))))
                                                             '#(syntax-object
                                                                () (top)
                                                                ()))))))
                                                   tmp330)
                                                 ((lambda (tmp335)
                                                    (if tmp335
                                                        (apply
                                                          (lambda (e1337
                                                                   e2336)
                                                            (cons
                                                              '#(syntax-object
                                                                 let (top)
                                                                 ())
                                                              (cons
                                                                '#(syntax-object
                                                                   do (top)
                                                                   ())
                                                                (cons
                                                                  (map (lambda (tmp339
                                                                                tmp338)
                                                                         (cons
                                                                           tmp338
                                                                           (cons
                                                                             tmp339
                                                                             '#(syntax-object
                                                                                ()
                                                                                (top)
                                                                                ()))))
                                                                       init315
                                                                       var316)
                                                                  (cons
                                                                    (cons
                                                                      '#(syntax-object
                                                                         if
                                                                         (top)
                                                                         ())
                                                                      (cons
                                                                        e0313
                                                                        (cons
                                                                          (cons
                                                                            '#(syntax-object
                                                                               begin
                                                                               (top)
                                                                               ())
                                                                            (cons
                                                                              e1337
                                                                              e2336))
                                                                          (cons
                                                                            (cons
                                                                              '#(syntax-object
                                                                                 begin
                                                                                 (top)
                                                                                 ())
                                                                              (append
                                                                                c311
                                                                                (cons
                                                                                  (cons
                                                                                    '#(syntax-object
                                                                                       do
                                                                                       (top)
                                                                                       ())
                                                                                    step327)
                                                                                  '#(syntax-object
                                                                                     ()
                                                                                     (top)
                                                                                     ()))))
                                                                            '#(syntax-object
                                                                               ()
                                                                               (top)
                                                                               ())))))
                                                                    '#(syntax-object
                                                                       ()
                                                                       (top)
                                                                       ()))))))
                                                          tmp335)
                                                        (syntax-error
                                                          tmp328)))
                                                   ($syntax-dispatch
                                                     tmp328
                                                     '(any . each-any)))))
                                            ($syntax-dispatch tmp328 '())))
                                         e1312))
                                     tmp326)
                                   (syntax-error tmp317)))
                              ($syntax-dispatch tmp317 'each-any)))
                           (map (lambda (v321 s320)
                                  ((lambda (tmp322)
                                     ((lambda (tmp323)
                                        (if tmp323
                                            (apply (lambda () v321) tmp323)
                                            ((lambda (tmp324)
                                               (if tmp324
                                                   (apply
                                                     (lambda (e325) e325)
                                                     tmp324)
                                                   (syntax-error
                                                     orig-x308)))
                                              ($syntax-dispatch
                                                tmp322
                                                '(any)))))
                                       ($syntax-dispatch tmp322 '())))
                                    s320))
                                var316
                                step314)))
                       tmp310)
                     (syntax-error tmp309)))
                ($syntax-dispatch
                  tmp309
                  '(_ #(each (any any . any))
                      (any . each-any)
                      .
                      each-any))))
             orig-x308)))
       (global-extend9
         'macro
         'quasiquote
         ((lambda ()
            (letrec* ([quasilist*204 (lambda (x305 y304)
                                       ((letrec ([f306 (lambda (x307)
                                                         (if (null? x307)
                                                             y304
                                                             (quasicons205
                                                               (car x307)
                                                               (f306
                                                                 (cdr x307)))))])
                                          f306)
                                         x305))]
                      [quasicons205 (lambda (x291 y290)
                                      ((lambda (tmp292)
                                         ((lambda (tmp293)
                                            (if tmp293
                                                (apply
                                                  (lambda (x295 y294)
                                                    ((lambda (tmp296)
                                                       ((lambda (tmp297)
                                                          (if tmp297
                                                              (apply
                                                                (lambda (dy298)
                                                                  ((lambda (tmp299)
                                                                     ((lambda (tmp300)
                                                                        (if tmp300
                                                                            (apply
                                                                              (lambda (dx301)
                                                                                (cons
                                                                                  '#(syntax-object
                                                                                     quote
                                                                                     (top)
                                                                                     ())
                                                                                  (cons
                                                                                    (cons
                                                                                      dx301
                                                                                      dy298)
                                                                                    '#(syntax-object
                                                                                       ()
                                                                                       (top)
                                                                                       ()))))
                                                                              tmp300)
                                                                            (if (null?
                                                                                  dy298)
                                                                                (cons
                                                                                  '#(syntax-object
                                                                                     list
                                                                                     (top)
                                                                                     ())
                                                                                  (cons
                                                                                    x295
                                                                                    '#(syntax-object
                                                                                       ()
                                                                                       (top)
                                                                                       ())))
                                                                                (cons
                                                                                  '#(syntax-object
                                                                                     cons
                                                                                     (top)
                                                                                     ())
                                                                                  (cons
                                                                                    x295
                                                                                    (cons
                                                                                      y294
                                                                                      '#(syntax-object
                                                                                         ()
                                                                                         (top)
                                                                                         ())))))))
                                                                       ($syntax-dispatch
                                                                         tmp299
                                                                         '(#(free-id
                                                                             #(syntax-object
                                                                               quote
                                                                               (top)
                                                                               (#(rib
                                                                                  (dy)
                                                                                  ((top))
                                                                                  ("i"))
                                                                                 #(rib
                                                                                   (x y)
                                                                                   ((top)
                                                                                     (top))
                                                                                   ("i" "i"))
                                                                                 #(rib
                                                                                   ()
                                                                                   ()
                                                                                   ())
                                                                                 #(rib
                                                                                   ()
                                                                                   ()
                                                                                   ())
                                                                                 #(rib
                                                                                   (x y)
                                                                                   ((top)
                                                                                     (top))
                                                                                   ("i" "i"))
                                                                                 #(rib
                                                                                   (quasi
                                                                                     vquasi
                                                                                     quasivector
                                                                                     quasiappend
                                                                                     quasicons
                                                                                     quasilist*)
                                                                                   ((top)
                                                                                     (top)
                                                                                     (top)
                                                                                     (top)
                                                                                     (top)
                                                                                     (top))
                                                                                   ("i" "i"
                                                                                        "i"
                                                                                        "i"
                                                                                        "i"
                                                                                        "i"))
                                                                                 #(rib
                                                                                   (invalid-ids-error
                                                                                    distinct-bound-ids?
                                                                                    valid-bound-ids?
                                                                                    bound-id-member?
                                                                                    bound-id=?
                                                                                    free-id=?
                                                                                    label->binding
                                                                                    id->label
                                                                                    gen-var
                                                                                    id->sym
                                                                                    id?
                                                                                    eval-transformer
                                                                                    displaced-lexical-error
                                                                                    extend-var-env*
                                                                                    extend-env*
                                                                                    extend-env
                                                                                    null-env
                                                                                    binding-value
                                                                                    binding-type
                                                                                    make-binding
                                                                                    gen-label
                                                                                    make-full-rib
                                                                                    extend-rib!
                                                                                    make-empty-rib
                                                                                    set-rib-label*!
                                                                                    set-rib-mark**!
                                                                                    set-rib-sym*!
                                                                                    rib-label*
                                                                                    rib-mark**
                                                                                    rib-sym*
                                                                                    rib?
                                                                                    make-rib
                                                                                    syntax-object
                                                                                    join-wraps
                                                                                    add-subst
                                                                                    top-subst*
                                                                                    same-marks?
                                                                                    add-mark
                                                                                    anti-mark
                                                                                    gen-mark
                                                                                    top-marked?
                                                                                    top-mark*
                                                                                    unannotate
                                                                                    source
                                                                                    strip
                                                                                    set-syntax-object-subst*!
                                                                                    set-syntax-object-mark*!
                                                                                    set-syntax-object-expression!
                                                                                    syntax-object-subst*
                                                                                    syntax-object-mark*
                                                                                    syntax-object-expression
                                                                                    syntax-object?
                                                                                    make-syntax-object
                                                                                    let-values
                                                                                    define-structure
                                                                                    andmap
                                                                                    self-evaluating?
                                                                                    build-lexical-var
                                                                                    build-letrec*
                                                                                    build-letrec
                                                                                    build-sequence
                                                                                    build-data
                                                                                    build-primref
                                                                                    build-lambda
                                                                                    build-global-assignment
                                                                                    build-lexical-assignment
                                                                                    build-lexical-reference
                                                                                    build-global-reference
                                                                                    build-conditional
                                                                                    build-application
                                                                                    global-lookup
                                                                                    global-extend
                                                                                    globals
                                                                                    strip-annotation
                                                                                    annotation-source
                                                                                    annotation-expression
                                                                                    annotation?
                                                                                    no-source
                                                                                    gensym-hook
                                                                                    error-hook
                                                                                    eval-hook)
                                                                                   ((top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top)
                                                                                    (top))
                                                                                   ("i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i"
                                                                                    "i")))))
                                                                            any))))
                                                                    x295))
                                                                tmp297)
                                                              ((lambda (tmp302)
                                                                 (if tmp302
                                                                     (apply
                                                                       (lambda (stuff303)
                                                                         (cons
                                                                           '#(syntax-object
                                                                              list
                                                                              (top)
                                                                              ())
                                                                           (cons
                                                                             x295
                                                                             stuff303)))
                                                                       tmp302)
                                                                     (cons
                                                                       '#(syntax-object
                                                                          cons
                                                                          (top)
                                                                          ())
                                                                       (cons
                                                                         x295
                                                                         (cons
                                                                           y294
                                                                           '#(syntax-object
                                                                              ()
                                                                              (top)
                                                                              ()))))))
                                                                ($syntax-dispatch
                                                                  tmp296
                                                                  '(#(free-id
                                                                      #(syntax-object
                                                                        list?
                                                                        (top)
                                                                        (#(rib
                                                                           (x y)
                                                                           ((top)
                                                                             (top))
                                                                           ("i" "i"))
                                                                          #(rib
                                                                            ()
                                                                            ()
                                                                            ())
                                                                          #(rib
                                                                            ()
                                                                            ()
                                                                            ())
                                                                          #(rib
                                                                            (x y)
                                                                            ((top)
                                                                              (top))
                                                                            ("i" "i"))
                                                                          #(rib
                                                                            (quasi
                                                                              vquasi
                                                                              quasivector
                                                                              quasiappend
                                                                              quasicons
                                                                              quasilist*)
                                                                            ((top)
                                                                              (top)
                                                                              (top)
                                                                              (top)
                                                                              (top)
                                                                              (top))
                                                                            ("i" "i"
                                                                                 "i"
                                                                                 "i"
                                                                                 "i"
                                                                                 "i"))
                                                                          #(rib
                                                                            (invalid-ids-error
                                                                             distinct-bound-ids?
                                                                             valid-bound-ids?
                                                                             bound-id-member?
                                                                             bound-id=?
                                                                             free-id=?
                                                                             label->binding
                                                                             id->label
                                                                             gen-var
                                                                             id->sym
                                                                             id?
                                                                             eval-transformer
                                                                             displaced-lexical-error
                                                                             extend-var-env*
                                                                             extend-env*
                                                                             extend-env
                                                                             null-env
                                                                             binding-value
                                                                             binding-type
                                                                             make-binding
                                                                             gen-label
                                                                             make-full-rib
                                                                             extend-rib!
                                                                             make-empty-rib
                                                                             set-rib-label*!
                                                                             set-rib-mark**!
                                                                             set-rib-sym*!
                                                                             rib-label*
                                                                             rib-mark**
                                                                             rib-sym*
                                                                             rib?
                                                                             make-rib
                                                                             syntax-object
                                                                             join-wraps
                                                                             add-subst
                                                                             top-subst*
                                                                             same-marks?
                                                                             add-mark
                                                                             anti-mark
                                                                             gen-mark
                                                                             top-marked?
                                                                             top-mark*
                                                                             unannotate
                                                                             source
                                                                             strip
                                                                             set-syntax-object-subst*!
                                                                             set-syntax-object-mark*!
                                                                             set-syntax-object-expression!
                                                                             syntax-object-subst*
                                                                             syntax-object-mark*
                                                                             syntax-object-expression
                                                                             syntax-object?
                                                                             make-syntax-object
                                                                             let-values
                                                                             define-structure
                                                                             andmap
                                                                             self-evaluating?
                                                                             build-lexical-var
                                                                             build-letrec*
                                                                             build-letrec
                                                                             build-sequence
                                                                             build-data
                                                                             build-primref
                                                                             build-lambda
                                                                             build-global-assignment
                                                                             build-lexical-assignment
                                                                             build-lexical-reference
                                                                             build-global-reference
                                                                             build-conditional
                                                                             build-application
                                                                             global-lookup
                                                                             global-extend
                                                                             globals
                                                                             strip-annotation
                                                                             annotation-source
                                                                             annotation-expression
                                                                             annotation?
                                                                             no-source
                                                                             gensym-hook
                                                                             error-hook
                                                                             eval-hook)
                                                                            ((top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top)
                                                                             (top))
                                                                            ("i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i")))))
                                                                     .
                                                                     any)))))
                                                         ($syntax-dispatch
                                                           tmp296
                                                           '(#(free-id
                                                               #(syntax-object
                                                                 quote
                                                                 (top)
                                                                 (#(rib
                                                                    (x y)
                                                                    ((top)
                                                                      (top))
                                                                    ("i" "i"))
                                                                   #(rib ()
                                                                     () ())
                                                                   #(rib ()
                                                                     () ())
                                                                   #(rib
                                                                     (x y)
                                                                     ((top)
                                                                       (top))
                                                                     ("i" "i"))
                                                                   #(rib
                                                                     (quasi
                                                                       vquasi
                                                                       quasivector
                                                                       quasiappend
                                                                       quasicons
                                                                       quasilist*)
                                                                     ((top)
                                                                       (top)
                                                                       (top)
                                                                       (top)
                                                                       (top)
                                                                       (top))
                                                                     ("i" "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"))
                                                                   #(rib
                                                                     (invalid-ids-error
                                                                      distinct-bound-ids?
                                                                      valid-bound-ids?
                                                                      bound-id-member?
                                                                      bound-id=?
                                                                      free-id=?
                                                                      label->binding
                                                                      id->label
                                                                      gen-var
                                                                      id->sym
                                                                      id?
                                                                      eval-transformer
                                                                      displaced-lexical-error
                                                                      extend-var-env*
                                                                      extend-env*
                                                                      extend-env
                                                                      null-env
                                                                      binding-value
                                                                      binding-type
                                                                      make-binding
                                                                      gen-label
                                                                      make-full-rib
                                                                      extend-rib!
                                                                      make-empty-rib
                                                                      set-rib-label*!
                                                                      set-rib-mark**!
                                                                      set-rib-sym*!
                                                                      rib-label*
                                                                      rib-mark**
                                                                      rib-sym*
                                                                      rib?
                                                                      make-rib
                                                                      syntax-object
                                                                      join-wraps
                                                                      add-subst
                                                                      top-subst*
                                                                      same-marks?
                                                                      add-mark
                                                                      anti-mark
                                                                      gen-mark
                                                                      top-marked?
                                                                      top-mark*
                                                                      unannotate
                                                                      source
                                                                      strip
                                                                      set-syntax-object-subst*!
                                                                      set-syntax-object-mark*!
                                                                      set-syntax-object-expression!
                                                                      syntax-object-subst*
                                                                      syntax-object-mark*
                                                                      syntax-object-expression
                                                                      syntax-object?
                                                                      make-syntax-object
                                                                      let-values
                                                                      define-structure
                                                                      andmap
                                                                      self-evaluating?
                                                                      build-lexical-var
                                                                      build-letrec*
                                                                      build-letrec
                                                                      build-sequence
                                                                      build-data
                                                                      build-primref
                                                                      build-lambda
                                                                      build-global-assignment
                                                                      build-lexical-assignment
                                                                      build-lexical-reference
                                                                      build-global-reference
                                                                      build-conditional
                                                                      build-application
                                                                      global-lookup
                                                                      global-extend
                                                                      globals
                                                                      strip-annotation
                                                                      annotation-source
                                                                      annotation-expression
                                                                      annotation?
                                                                      no-source
                                                                      gensym-hook
                                                                      error-hook
                                                                      eval-hook)
                                                                     ((top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top)
                                                                      (top))
                                                                     ("i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i"
                                                                      "i")))))
                                                              any))))
                                                      y294))
                                                  tmp293)
                                                (syntax-error tmp292)))
                                           ($syntax-dispatch
                                             tmp292
                                             '(any any))))
                                        (list x291 y290)))]
                      [quasiappend206 (lambda (x278 y277)
                                        ((lambda (ls285)
                                           (if (null? ls285)
                                               '#(syntax-object '() (top)
                                                  ())
                                               (if (null? (cdr ls285))
                                                   (car ls285)
                                                   ((lambda (tmp286)
                                                      ((lambda (tmp287)
                                                         (if tmp287
                                                             (apply
                                                               (lambda (p288)
                                                                 (cons
                                                                   '#(syntax-object
                                                                      append
                                                                      (top)
                                                                      ())
                                                                   p288))
                                                               tmp287)
                                                             (syntax-error
                                                               tmp286)))
                                                        ($syntax-dispatch
                                                          tmp286
                                                          'each-any)))
                                                     ls285))))
                                          ((letrec ([f279 (lambda (x280)
                                                            (if (null?
                                                                  x280)
                                                                ((lambda (tmp281)
                                                                   ((lambda (tmp282)
                                                                      (if tmp282
                                                                          (apply
                                                                            (lambda ()
                                                                              '())
                                                                            tmp282)
                                                                          (list
                                                                            y277)))
                                                                     ($syntax-dispatch
                                                                       tmp281
                                                                       '(#(free-id
                                                                           #(syntax-object
                                                                             quote
                                                                             (top)
                                                                             (#(rib
                                                                                ()
                                                                                ()
                                                                                ())
                                                                               #(rib
                                                                                 (x)
                                                                                 ((top))
                                                                                 ("i"))
                                                                               #(rib
                                                                                 (f)
                                                                                 ((top))
                                                                                 ("i"))
                                                                               #(rib
                                                                                 ()
                                                                                 ()
                                                                                 ())
                                                                               #(rib
                                                                                 ()
                                                                                 ()
                                                                                 ())
                                                                               #(rib
                                                                                 (x y)
                                                                                 ((top)
                                                                                   (top))
                                                                                 ("i" "i"))
                                                                               #(rib
                                                                                 (quasi
                                                                                   vquasi
                                                                                   quasivector
                                                                                   quasiappend
                                                                                   quasicons
                                                                                   quasilist*)
                                                                                 ((top)
                                                                                   (top)
                                                                                   (top)
                                                                                   (top)
                                                                                   (top)
                                                                                   (top))
                                                                                 ("i" "i"
                                                                                      "i"
                                                                                      "i"
                                                                                      "i"
                                                                                      "i"))
                                                                               #(rib
                                                                                 (invalid-ids-error
                                                                                  distinct-bound-ids?
                                                                                  valid-bound-ids?
                                                                                  bound-id-member?
                                                                                  bound-id=?
                                                                                  free-id=?
                                                                                  label->binding
                                                                                  id->label
                                                                                  gen-var
                                                                                  id->sym
                                                                                  id?
                                                                                  eval-transformer
                                                                                  displaced-lexical-error
                                                                                  extend-var-env*
                                                                                  extend-env*
                                                                                  extend-env
                                                                                  null-env
                                                                                  binding-value
                                                                                  binding-type
                                                                                  make-binding
                                                                                  gen-label
                                                                                  make-full-rib
                                                                                  extend-rib!
                                                                                  make-empty-rib
                                                                                  set-rib-label*!
                                                                                  set-rib-mark**!
                                                                                  set-rib-sym*!
                                                                                  rib-label*
                                                                                  rib-mark**
                                                                                  rib-sym*
                                                                                  rib?
                                                                                  make-rib
                                                                                  syntax-object
                                                                                  join-wraps
                                                                                  add-subst
                                                                                  top-subst*
                                                                                  same-marks?
                                                                                  add-mark
                                                                                  anti-mark
                                                                                  gen-mark
                                                                                  top-marked?
                                                                                  top-mark*
                                                                                  unannotate
                                                                                  source
                                                                                  strip
                                                                                  set-syntax-object-subst*!
                                                                                  set-syntax-object-mark*!
                                                                                  set-syntax-object-expression!
                                                                                  syntax-object-subst*
                                                                                  syntax-object-mark*
                                                                                  syntax-object-expression
                                                                                  syntax-object?
                                                                                  make-syntax-object
                                                                                  let-values
                                                                                  define-structure
                                                                                  andmap
                                                                                  self-evaluating?
                                                                                  build-lexical-var
                                                                                  build-letrec*
                                                                                  build-letrec
                                                                                  build-sequence
                                                                                  build-data
                                                                                  build-primref
                                                                                  build-lambda
                                                                                  build-global-assignment
                                                                                  build-lexical-assignment
                                                                                  build-lexical-reference
                                                                                  build-global-reference
                                                                                  build-conditional
                                                                                  build-application
                                                                                  global-lookup
                                                                                  global-extend
                                                                                  globals
                                                                                  strip-annotation
                                                                                  annotation-source
                                                                                  annotation-expression
                                                                                  annotation?
                                                                                  no-source
                                                                                  gensym-hook
                                                                                  error-hook
                                                                                  eval-hook)
                                                                                 ((top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top))
                                                                                 ("i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i")))))
                                                                          ()))))
                                                                  y277)
                                                                ((lambda (tmp283)
                                                                   ((lambda (tmp284)
                                                                      (if tmp284
                                                                          (apply
                                                                            (lambda ()
                                                                              (f279
                                                                                (cdr x280)))
                                                                            tmp284)
                                                                          (cons
                                                                            (car x280)
                                                                            (f279
                                                                              (cdr x280)))))
                                                                     ($syntax-dispatch
                                                                       tmp283
                                                                       '(#(free-id
                                                                           #(syntax-object
                                                                             quote
                                                                             (top)
                                                                             (#(rib
                                                                                ()
                                                                                ()
                                                                                ())
                                                                               #(rib
                                                                                 (x)
                                                                                 ((top))
                                                                                 ("i"))
                                                                               #(rib
                                                                                 (f)
                                                                                 ((top))
                                                                                 ("i"))
                                                                               #(rib
                                                                                 ()
                                                                                 ()
                                                                                 ())
                                                                               #(rib
                                                                                 ()
                                                                                 ()
                                                                                 ())
                                                                               #(rib
                                                                                 (x y)
                                                                                 ((top)
                                                                                   (top))
                                                                                 ("i" "i"))
                                                                               #(rib
                                                                                 (quasi
                                                                                   vquasi
                                                                                   quasivector
                                                                                   quasiappend
                                                                                   quasicons
                                                                                   quasilist*)
                                                                                 ((top)
                                                                                   (top)
                                                                                   (top)
                                                                                   (top)
                                                                                   (top)
                                                                                   (top))
                                                                                 ("i" "i"
                                                                                      "i"
                                                                                      "i"
                                                                                      "i"
                                                                                      "i"))
                                                                               #(rib
                                                                                 (invalid-ids-error
                                                                                  distinct-bound-ids?
                                                                                  valid-bound-ids?
                                                                                  bound-id-member?
                                                                                  bound-id=?
                                                                                  free-id=?
                                                                                  label->binding
                                                                                  id->label
                                                                                  gen-var
                                                                                  id->sym
                                                                                  id?
                                                                                  eval-transformer
                                                                                  displaced-lexical-error
                                                                                  extend-var-env*
                                                                                  extend-env*
                                                                                  extend-env
                                                                                  null-env
                                                                                  binding-value
                                                                                  binding-type
                                                                                  make-binding
                                                                                  gen-label
                                                                                  make-full-rib
                                                                                  extend-rib!
                                                                                  make-empty-rib
                                                                                  set-rib-label*!
                                                                                  set-rib-mark**!
                                                                                  set-rib-sym*!
                                                                                  rib-label*
                                                                                  rib-mark**
                                                                                  rib-sym*
                                                                                  rib?
                                                                                  make-rib
                                                                                  syntax-object
                                                                                  join-wraps
                                                                                  add-subst
                                                                                  top-subst*
                                                                                  same-marks?
                                                                                  add-mark
                                                                                  anti-mark
                                                                                  gen-mark
                                                                                  top-marked?
                                                                                  top-mark*
                                                                                  unannotate
                                                                                  source
                                                                                  strip
                                                                                  set-syntax-object-subst*!
                                                                                  set-syntax-object-mark*!
                                                                                  set-syntax-object-expression!
                                                                                  syntax-object-subst*
                                                                                  syntax-object-mark*
                                                                                  syntax-object-expression
                                                                                  syntax-object?
                                                                                  make-syntax-object
                                                                                  let-values
                                                                                  define-structure
                                                                                  andmap
                                                                                  self-evaluating?
                                                                                  build-lexical-var
                                                                                  build-letrec*
                                                                                  build-letrec
                                                                                  build-sequence
                                                                                  build-data
                                                                                  build-primref
                                                                                  build-lambda
                                                                                  build-global-assignment
                                                                                  build-lexical-assignment
                                                                                  build-lexical-reference
                                                                                  build-global-reference
                                                                                  build-conditional
                                                                                  build-application
                                                                                  global-lookup
                                                                                  global-extend
                                                                                  globals
                                                                                  strip-annotation
                                                                                  annotation-source
                                                                                  annotation-expression
                                                                                  annotation?
                                                                                  no-source
                                                                                  gensym-hook
                                                                                  error-hook
                                                                                  eval-hook)
                                                                                 ((top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top)
                                                                                  (top))
                                                                                 ("i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i"
                                                                                  "i")))))
                                                                          ()))))
                                                                  (car x280))))])
                                             f279)
                                            x278)))]
                      [quasivector207 (lambda (x255)
                                        ((lambda (tmp256)
                                           ((lambda (pat-x257)
                                              ((lambda (tmp258)
                                                 ((lambda (tmp259)
                                                    (if tmp259
                                                        (apply
                                                          (lambda (x260)
                                                            (cons
                                                              '#(syntax-object
                                                                 quote
                                                                 (top) ())
                                                              (cons
                                                                (list->vector
                                                                  x260)
                                                                '#(syntax-object
                                                                   () (top)
                                                                   ()))))
                                                          tmp259)
                                                        ((letrec ([f263 (lambda (x265
                                                                                 k264)
                                                                          ((lambda (tmp266)
                                                                             ((lambda (tmp267)
                                                                                (if tmp267
                                                                                    (apply
                                                                                      (lambda (x268)
                                                                                        (k264
                                                                                          (map (lambda (tmp269)
                                                                                                 (cons
                                                                                                   '#(syntax-object
                                                                                                      quote
                                                                                                      (top)
                                                                                                      ())
                                                                                                   (cons
                                                                                                     tmp269
                                                                                                     '#(syntax-object
                                                                                                        ()
                                                                                                        (top)
                                                                                                        ()))))
                                                                                               x268)))
                                                                                      tmp267)
                                                                                    ((lambda (tmp270)
                                                                                       (if tmp270
                                                                                           (apply
                                                                                             (lambda (x271)
                                                                                               (k264
                                                                                                 x271))
                                                                                             tmp270)
                                                                                           ((lambda (tmp273)
                                                                                              (if tmp273
                                                                                                  (apply
                                                                                                    (lambda (x275
                                                                                                             y274)
                                                                                                      (f263
                                                                                                        y274
                                                                                                        (lambda (ls276)
                                                                                                          (k264
                                                                                                            (cons
                                                                                                              x275
                                                                                                              ls276)))))
                                                                                                    tmp273)
                                                                                                  (cons
                                                                                                    '#(syntax-object
                                                                                                       list->vector
                                                                                                       (top)
                                                                                                       ())
                                                                                                    (cons
                                                                                                      pat-x257
                                                                                                      '#(syntax-object
                                                                                                         ()
                                                                                                         (top)
                                                                                                         ())))))
                                                                                             ($syntax-dispatch
                                                                                               tmp266
                                                                                               '(#(free-id
                                                                                                   #(syntax-object
                                                                                                     cons
                                                                                                     (top)
                                                                                                     (#(rib
                                                                                                        ()
                                                                                                        ()
                                                                                                        ())
                                                                                                       #(rib
                                                                                                         (x k)
                                                                                                         ((top)
                                                                                                           (top))
                                                                                                         ("i" "i"))
                                                                                                       #(rib
                                                                                                         (f)
                                                                                                         ((top))
                                                                                                         ("i"))
                                                                                                       #(rib
                                                                                                         (pat-x)
                                                                                                         ((top))
                                                                                                         ("i"))
                                                                                                       #(rib
                                                                                                         ()
                                                                                                         ()
                                                                                                         ())
                                                                                                       #(rib
                                                                                                         ()
                                                                                                         ()
                                                                                                         ())
                                                                                                       #(rib
                                                                                                         (x)
                                                                                                         ((top))
                                                                                                         ("i"))
                                                                                                       #(rib
                                                                                                         (quasi
                                                                                                           vquasi
                                                                                                           quasivector
                                                                                                           quasiappend
                                                                                                           quasicons
                                                                                                           quasilist*)
                                                                                                         ((top)
                                                                                                           (top)
                                                                                                           (top)
                                                                                                           (top)
                                                                                                           (top)
                                                                                                           (top))
                                                                                                         ("i" "i"
                                                                                                              "i"
                                                                                                              "i"
                                                                                                              "i"
                                                                                                              "i"))
                                                                                                       #(rib
                                                                                                         (invalid-ids-error
                                                                                                          distinct-bound-ids?
                                                                                                          valid-bound-ids?
                                                                                                          bound-id-member?
                                                                                                          bound-id=?
                                                                                                          free-id=?
                                                                                                          label->binding
                                                                                                          id->label
                                                                                                          gen-var
                                                                                                          id->sym
                                                                                                          id?
                                                                                                          eval-transformer
                                                                                                          displaced-lexical-error
                                                                                                          extend-var-env*
                                                                                                          extend-env*
                                                                                                          extend-env
                                                                                                          null-env
                                                                                                          binding-value
                                                                                                          binding-type
                                                                                                          make-binding
                                                                                                          gen-label
                                                                                                          make-full-rib
                                                                                                          extend-rib!
                                                                                                          make-empty-rib
                                                                                                          set-rib-label*!
                                                                                                          set-rib-mark**!
                                                                                                          set-rib-sym*!
                                                                                                          rib-label*
                                                                                                          rib-mark**
                                                                                                          rib-sym*
                                                                                                          rib?
                                                                                                          make-rib
                                                                                                          syntax-object
                                                                                                          join-wraps
                                                                                                          add-subst
                                                                                                          top-subst*
                                                                                                          same-marks?
                                                                                                          add-mark
                                                                                                          anti-mark
                                                                                                          gen-mark
                                                                                                          top-marked?
                                                                                                          top-mark*
                                                                                                          unannotate
                                                                                                          source
                                                                                                          strip
                                                                                                          set-syntax-object-subst*!
                                                                                                          set-syntax-object-mark*!
                                                                                                          set-syntax-object-expression!
                                                                                                          syntax-object-subst*
                                                                                                          syntax-object-mark*
                                                                                                          syntax-object-expression
                                                                                                          syntax-object?
                                                                                                          make-syntax-object
                                                                                                          let-values
                                                                                                          define-structure
                                                                                                          andmap
                                                                                                          self-evaluating?
                                                                                                          build-lexical-var
                                                                                                          build-letrec*
                                                                                                          build-letrec
                                                                                                          build-sequence
                                                                                                          build-data
                                                                                                          build-primref
                                                                                                          build-lambda
                                                                                                          build-global-assignment
                                                                                                          build-lexical-assignment
                                                                                                          build-lexical-reference
                                                                                                          build-global-reference
                                                                                                          build-conditional
                                                                                                          build-application
                                                                                                          global-lookup
                                                                                                          global-extend
                                                                                                          globals
                                                                                                          strip-annotation
                                                                                                          annotation-source
                                                                                                          annotation-expression
                                                                                                          annotation?
                                                                                                          no-source
                                                                                                          gensym-hook
                                                                                                          error-hook
                                                                                                          eval-hook)
                                                                                                         ((top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top)
                                                                                                          (top))
                                                                                                         ("i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i"
                                                                                                          "i")))))
                                                                                                  any
                                                                                                  any)))))
                                                                                      ($syntax-dispatch
                                                                                        tmp266
                                                                                        '(#(free-id
                                                                                            #(syntax-object
                                                                                              list?
                                                                                              (top)
                                                                                              (#(rib
                                                                                                 ()
                                                                                                 ()
                                                                                                 ())
                                                                                                #(rib
                                                                                                  (x k)
                                                                                                  ((top)
                                                                                                    (top))
                                                                                                  ("i" "i"))
                                                                                                #(rib
                                                                                                  (f)
                                                                                                  ((top))
                                                                                                  ("i"))
                                                                                                #(rib
                                                                                                  (pat-x)
                                                                                                  ((top))
                                                                                                  ("i"))
                                                                                                #(rib
                                                                                                  ()
                                                                                                  ()
                                                                                                  ())
                                                                                                #(rib
                                                                                                  ()
                                                                                                  ()
                                                                                                  ())
                                                                                                #(rib
                                                                                                  (x)
                                                                                                  ((top))
                                                                                                  ("i"))
                                                                                                #(rib
                                                                                                  (quasi
                                                                                                    vquasi
                                                                                                    quasivector
                                                                                                    quasiappend
                                                                                                    quasicons
                                                                                                    quasilist*)
                                                                                                  ((top)
                                                                                                    (top)
                                                                                                    (top)
                                                                                                    (top)
                                                                                                    (top)
                                                                                                    (top))
                                                                                                  ("i" "i"
                                                                                                       "i"
                                                                                                       "i"
                                                                                                       "i"
                                                                                                       "i"))
                                                                                                #(rib
                                                                                                  (invalid-ids-error
                                                                                                   distinct-bound-ids?
                                                                                                   valid-bound-ids?
                                                                                                   bound-id-member?
                                                                                                   bound-id=?
                                                                                                   free-id=?
                                                                                                   label->binding
                                                                                                   id->label
                                                                                                   gen-var
                                                                                                   id->sym
                                                                                                   id?
                                                                                                   eval-transformer
                                                                                                   displaced-lexical-error
                                                                                                   extend-var-env*
                                                                                                   extend-env*
                                                                                                   extend-env
                                                                                                   null-env
                                                                                                   binding-value
                                                                                                   binding-type
                                                                                                   make-binding
                                                                                                   gen-label
                                                                                                   make-full-rib
                                                                                                   extend-rib!
                                                                                                   make-empty-rib
                                                                                                   set-rib-label*!
                                                                                                   set-rib-mark**!
                                                                                                   set-rib-sym*!
                                                                                                   rib-label*
                                                                                                   rib-mark**
                                                                                                   rib-sym*
                                                                                                   rib?
                                                                                                   make-rib
                                                                                                   syntax-object
                                                                                                   join-wraps
                                                                                                   add-subst
                                                                                                   top-subst*
                                                                                                   same-marks?
                                                                                                   add-mark
                                                                                                   anti-mark
                                                                                                   gen-mark
                                                                                                   top-marked?
                                                                                                   top-mark*
                                                                                                   unannotate
                                                                                                   source
                                                                                                   strip
                                                                                                   set-syntax-object-subst*!
                                                                                                   set-syntax-object-mark*!
                                                                                                   set-syntax-object-expression!
                                                                                                   syntax-object-subst*
                                                                                                   syntax-object-mark*
                                                                                                   syntax-object-expression
                                                                                                   syntax-object?
                                                                                                   make-syntax-object
                                                                                                   let-values
                                                                                                   define-structure
                                                                                                   andmap
                                                                                                   self-evaluating?
                                                                                                   build-lexical-var
                                                                                                   build-letrec*
                                                                                                   build-letrec
                                                                                                   build-sequence
                                                                                                   build-data
                                                                                                   build-primref
                                                                                                   build-lambda
                                                                                                   build-global-assignment
                                                                                                   build-lexical-assignment
                                                                                                   build-lexical-reference
                                                                                                   build-global-reference
                                                                                                   build-conditional
                                                                                                   build-application
                                                                                                   global-lookup
                                                                                                   global-extend
                                                                                                   globals
                                                                                                   strip-annotation
                                                                                                   annotation-source
                                                                                                   annotation-expression
                                                                                                   annotation?
                                                                                                   no-source
                                                                                                   gensym-hook
                                                                                                   error-hook
                                                                                                   eval-hook)
                                                                                                  ((top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top)
                                                                                                   (top))
                                                                                                  ("i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i"
                                                                                                   "i")))))
                                                                                           .
                                                                                           each-any)))))
                                                                               ($syntax-dispatch
                                                                                 tmp266
                                                                                 '(#(free-id
                                                                                     #(syntax-object
                                                                                       quote
                                                                                       (top)
                                                                                       (#(rib
                                                                                          ()
                                                                                          ()
                                                                                          ())
                                                                                         #(rib
                                                                                           (x k)
                                                                                           ((top)
                                                                                             (top))
                                                                                           ("i" "i"))
                                                                                         #(rib
                                                                                           (f)
                                                                                           ((top))
                                                                                           ("i"))
                                                                                         #(rib
                                                                                           (pat-x)
                                                                                           ((top))
                                                                                           ("i"))
                                                                                         #(rib
                                                                                           ()
                                                                                           ()
                                                                                           ())
                                                                                         #(rib
                                                                                           ()
                                                                                           ()
                                                                                           ())
                                                                                         #(rib
                                                                                           (x)
                                                                                           ((top))
                                                                                           ("i"))
                                                                                         #(rib
                                                                                           (quasi
                                                                                             vquasi
                                                                                             quasivector
                                                                                             quasiappend
                                                                                             quasicons
                                                                                             quasilist*)
                                                                                           ((top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top)
                                                                                             (top))
                                                                                           ("i" "i"
                                                                                                "i"
                                                                                                "i"
                                                                                                "i"
                                                                                                "i"))
                                                                                         #(rib
                                                                                           (invalid-ids-error
                                                                                            distinct-bound-ids?
                                                                                            valid-bound-ids?
                                                                                            bound-id-member?
                                                                                            bound-id=?
                                                                                            free-id=?
                                                                                            label->binding
                                                                                            id->label
                                                                                            gen-var
                                                                                            id->sym
                                                                                            id?
                                                                                            eval-transformer
                                                                                            displaced-lexical-error
                                                                                            extend-var-env*
                                                                                            extend-env*
                                                                                            extend-env
                                                                                            null-env
                                                                                            binding-value
                                                                                            binding-type
                                                                                            make-binding
                                                                                            gen-label
                                                                                            make-full-rib
                                                                                            extend-rib!
                                                                                            make-empty-rib
                                                                                            set-rib-label*!
                                                                                            set-rib-mark**!
                                                                                            set-rib-sym*!
                                                                                            rib-label*
                                                                                            rib-mark**
                                                                                            rib-sym*
                                                                                            rib?
                                                                                            make-rib
                                                                                            syntax-object
                                                                                            join-wraps
                                                                                            add-subst
                                                                                            top-subst*
                                                                                            same-marks?
                                                                                            add-mark
                                                                                            anti-mark
                                                                                            gen-mark
                                                                                            top-marked?
                                                                                            top-mark*
                                                                                            unannotate
                                                                                            source
                                                                                            strip
                                                                                            set-syntax-object-subst*!
                                                                                            set-syntax-object-mark*!
                                                                                            set-syntax-object-expression!
                                                                                            syntax-object-subst*
                                                                                            syntax-object-mark*
                                                                                            syntax-object-expression
                                                                                            syntax-object?
                                                                                            make-syntax-object
                                                                                            let-values
                                                                                            define-structure
                                                                                            andmap
                                                                                            self-evaluating?
                                                                                            build-lexical-var
                                                                                            build-letrec*
                                                                                            build-letrec
                                                                                            build-sequence
                                                                                            build-data
                                                                                            build-primref
                                                                                            build-lambda
                                                                                            build-global-assignment
                                                                                            build-lexical-assignment
                                                                                            build-lexical-reference
                                                                                            build-global-reference
                                                                                            build-conditional
                                                                                            build-application
                                                                                            global-lookup
                                                                                            global-extend
                                                                                            globals
                                                                                            strip-annotation
                                                                                            annotation-source
                                                                                            annotation-expression
                                                                                            annotation?
                                                                                            no-source
                                                                                            gensym-hook
                                                                                            error-hook
                                                                                            eval-hook)
                                                                                           ((top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top)
                                                                                            (top))
                                                                                           ("i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i"
                                                                                            "i")))))
                                                                                    each-any))))
                                                                            x265))])
                                                           f263)
                                                          x255
                                                          (lambda (ls262)
                                                            (cons
                                                              '#(syntax-object
                                                                 vector
                                                                 (top) ())
                                                              (append
                                                                ls262
                                                                '()))))))
                                                   ($syntax-dispatch
                                                     tmp258
                                                     '(#(free-id
                                                         #(syntax-object
                                                           quote (top)
                                                           (#(rib (pat-x)
                                                              ((top))
                                                              ("i"))
                                                             #(rib () ()
                                                               ())
                                                             #(rib () ()
                                                               ())
                                                             #(rib (x)
                                                               ((top))
                                                               ("i"))
                                                             #(rib
                                                               (quasi
                                                                 vquasi
                                                                 quasivector
                                                                 quasiappend
                                                                 quasicons
                                                                 quasilist*)
                                                               ((top) (top)
                                                                 (top)
                                                                 (top)
                                                                 (top)
                                                                 (top))
                                                               ("i" "i" "i"
                                                                    "i" "i"
                                                                    "i"))
                                                             #(rib
                                                               (invalid-ids-error
                                                                distinct-bound-ids?
                                                                valid-bound-ids?
                                                                bound-id-member?
                                                                bound-id=?
                                                                free-id=?
                                                                label->binding
                                                                id->label
                                                                gen-var
                                                                id->sym id?
                                                                eval-transformer
                                                                displaced-lexical-error
                                                                extend-var-env*
                                                                extend-env*
                                                                extend-env
                                                                null-env
                                                                binding-value
                                                                binding-type
                                                                make-binding
                                                                gen-label
                                                                make-full-rib
                                                                extend-rib!
                                                                make-empty-rib
                                                                set-rib-label*!
                                                                set-rib-mark**!
                                                                set-rib-sym*!
                                                                rib-label*
                                                                rib-mark**
                                                                rib-sym*
                                                                rib?
                                                                make-rib
                                                                syntax-object
                                                                join-wraps
                                                                add-subst
                                                                top-subst*
                                                                same-marks?
                                                                add-mark
                                                                anti-mark
                                                                gen-mark
                                                                top-marked?
                                                                top-mark*
                                                                unannotate
                                                                source
                                                                strip
                                                                set-syntax-object-subst*!
                                                                set-syntax-object-mark*!
                                                                set-syntax-object-expression!
                                                                syntax-object-subst*
                                                                syntax-object-mark*
                                                                syntax-object-expression
                                                                syntax-object?
                                                                make-syntax-object
                                                                let-values
                                                                define-structure
                                                                andmap
                                                                self-evaluating?
                                                                build-lexical-var
                                                                build-letrec*
                                                                build-letrec
                                                                build-sequence
                                                                build-data
                                                                build-primref
                                                                build-lambda
                                                                build-global-assignment
                                                                build-lexical-assignment
                                                                build-lexical-reference
                                                                build-global-reference
                                                                build-conditional
                                                                build-application
                                                                global-lookup
                                                                global-extend
                                                                globals
                                                                strip-annotation
                                                                annotation-source
                                                                annotation-expression
                                                                annotation?
                                                                no-source
                                                                gensym-hook
                                                                error-hook
                                                                eval-hook)
                                                               ((top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top) (top)
                                                                (top))
                                                               ("i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i" "i"
                                                                "i" "i"
                                                                "i")))))
                                                        each-any))))
                                                pat-x257))
                                             tmp256))
                                          x255))]
                      [vquasi208 (lambda (p239 lev238)
                                   ((lambda (tmp240)
                                      ((lambda (tmp241)
                                         (if tmp241
                                             (apply
                                               (lambda (p243 q242)
                                                 ((lambda (tmp244)
                                                    ((lambda (tmp245)
                                                       (if tmp245
                                                           (apply
                                                             (lambda (p246)
                                                               (if (= lev238
                                                                      '0)
                                                                   (quasilist*204
                                                                     p246
                                                                     (vquasi208
                                                                       q242
                                                                       lev238))
                                                                   (quasicons205
                                                                     (quasicons205
                                                                       '#(syntax-object
                                                                          'unquote
                                                                          (top)
                                                                          ())
                                                                       (quasi209
                                                                         p246
                                                                         (- lev238
                                                                            '1)))
                                                                     (vquasi208
                                                                       q242
                                                                       lev238))))
                                                             tmp245)
                                                           ((lambda (tmp249)
                                                              (if tmp249
                                                                  (apply
                                                                    (lambda (p250)
                                                                      (if (= lev238
                                                                             '0)
                                                                          (quasiappend206
                                                                            p250
                                                                            (vquasi208
                                                                              q242
                                                                              lev238))
                                                                          (quasicons205
                                                                            (quasicons205
                                                                              '#(syntax-object
                                                                                 'unquote-splicing
                                                                                 (top)
                                                                                 ())
                                                                              (quasi209
                                                                                p250
                                                                                (- lev238
                                                                                   '1)))
                                                                            (vquasi208
                                                                              q242
                                                                              lev238))))
                                                                    tmp249)
                                                                  ((lambda (p253)
                                                                     (quasicons205
                                                                       (quasi209
                                                                         p253
                                                                         lev238)
                                                                       (vquasi208
                                                                         q242
                                                                         lev238)))
                                                                    tmp244)))
                                                             ($syntax-dispatch
                                                               tmp244
                                                               '(#(free-id
                                                                   #(syntax-object
                                                                     unquote-splicing
                                                                     (top)
                                                                     (#(rib
                                                                        (p q)
                                                                        ((top)
                                                                          (top))
                                                                        ("i" "i"))
                                                                       #(rib
                                                                         ()
                                                                         ()
                                                                         ())
                                                                       #(rib
                                                                         (p lev)
                                                                         ((top)
                                                                           (top))
                                                                         ("i" "i"))
                                                                       #(rib
                                                                         (quasi
                                                                           vquasi
                                                                           quasivector
                                                                           quasiappend
                                                                           quasicons
                                                                           quasilist*)
                                                                         ((top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top)
                                                                           (top))
                                                                         ("i" "i"
                                                                              "i"
                                                                              "i"
                                                                              "i"
                                                                              "i"))
                                                                       #(rib
                                                                         (invalid-ids-error
                                                                          distinct-bound-ids?
                                                                          valid-bound-ids?
                                                                          bound-id-member?
                                                                          bound-id=?
                                                                          free-id=?
                                                                          label->binding
                                                                          id->label
                                                                          gen-var
                                                                          id->sym
                                                                          id?
                                                                          eval-transformer
                                                                          displaced-lexical-error
                                                                          extend-var-env*
                                                                          extend-env*
                                                                          extend-env
                                                                          null-env
                                                                          binding-value
                                                                          binding-type
                                                                          make-binding
                                                                          gen-label
                                                                          make-full-rib
                                                                          extend-rib!
                                                                          make-empty-rib
                                                                          set-rib-label*!
                                                                          set-rib-mark**!
                                                                          set-rib-sym*!
                                                                          rib-label*
                                                                          rib-mark**
                                                                          rib-sym*
                                                                          rib?
                                                                          make-rib
                                                                          syntax-object
                                                                          join-wraps
                                                                          add-subst
                                                                          top-subst*
                                                                          same-marks?
                                                                          add-mark
                                                                          anti-mark
                                                                          gen-mark
                                                                          top-marked?
                                                                          top-mark*
                                                                          unannotate
                                                                          source
                                                                          strip
                                                                          set-syntax-object-subst*!
                                                                          set-syntax-object-mark*!
                                                                          set-syntax-object-expression!
                                                                          syntax-object-subst*
                                                                          syntax-object-mark*
                                                                          syntax-object-expression
                                                                          syntax-object?
                                                                          make-syntax-object
                                                                          let-values
                                                                          define-structure
                                                                          andmap
                                                                          self-evaluating?
                                                                          build-lexical-var
                                                                          build-letrec*
                                                                          build-letrec
                                                                          build-sequence
                                                                          build-data
                                                                          build-primref
                                                                          build-lambda
                                                                          build-global-assignment
                                                                          build-lexical-assignment
                                                                          build-lexical-reference
                                                                          build-global-reference
                                                                          build-conditional
                                                                          build-application
                                                                          global-lookup
                                                                          global-extend
                                                                          globals
                                                                          strip-annotation
                                                                          annotation-source
                                                                          annotation-expression
                                                                          annotation?
                                                                          no-source
                                                                          gensym-hook
                                                                          error-hook
                                                                          eval-hook)
                                                                         ((top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top))
                                                                         ("i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i"
                                                                          "i")))))
                                                                  .
                                                                  each-any)))))
                                                      ($syntax-dispatch
                                                        tmp244
                                                        '(#(free-id
                                                            #(syntax-object
                                                              unquote (top)
                                                              (#(rib (p q)
                                                                 ((top)
                                                                   (top))
                                                                 ("i" "i"))
                                                                #(rib () ()
                                                                  ())
                                                                #(rib
                                                                  (p lev)
                                                                  ((top)
                                                                    (top))
                                                                  ("i" "i"))
                                                                #(rib
                                                                  (quasi
                                                                    vquasi
                                                                    quasivector
                                                                    quasiappend
                                                                    quasicons
                                                                    quasilist*)
                                                                  ((top)
                                                                    (top)
                                                                    (top)
                                                                    (top)
                                                                    (top)
                                                                    (top))
                                                                  ("i" "i"
                                                                       "i"
                                                                       "i"
                                                                       "i"
                                                                       "i"))
                                                                #(rib
                                                                  (invalid-ids-error
                                                                   distinct-bound-ids?
                                                                   valid-bound-ids?
                                                                   bound-id-member?
                                                                   bound-id=?
                                                                   free-id=?
                                                                   label->binding
                                                                   id->label
                                                                   gen-var
                                                                   id->sym
                                                                   id?
                                                                   eval-transformer
                                                                   displaced-lexical-error
                                                                   extend-var-env*
                                                                   extend-env*
                                                                   extend-env
                                                                   null-env
                                                                   binding-value
                                                                   binding-type
                                                                   make-binding
                                                                   gen-label
                                                                   make-full-rib
                                                                   extend-rib!
                                                                   make-empty-rib
                                                                   set-rib-label*!
                                                                   set-rib-mark**!
                                                                   set-rib-sym*!
                                                                   rib-label*
                                                                   rib-mark**
                                                                   rib-sym*
                                                                   rib?
                                                                   make-rib
                                                                   syntax-object
                                                                   join-wraps
                                                                   add-subst
                                                                   top-subst*
                                                                   same-marks?
                                                                   add-mark
                                                                   anti-mark
                                                                   gen-mark
                                                                   top-marked?
                                                                   top-mark*
                                                                   unannotate
                                                                   source
                                                                   strip
                                                                   set-syntax-object-subst*!
                                                                   set-syntax-object-mark*!
                                                                   set-syntax-object-expression!
                                                                   syntax-object-subst*
                                                                   syntax-object-mark*
                                                                   syntax-object-expression
                                                                   syntax-object?
                                                                   make-syntax-object
                                                                   let-values
                                                                   define-structure
                                                                   andmap
                                                                   self-evaluating?
                                                                   build-lexical-var
                                                                   build-letrec*
                                                                   build-letrec
                                                                   build-sequence
                                                                   build-data
                                                                   build-primref
                                                                   build-lambda
                                                                   build-global-assignment
                                                                   build-lexical-assignment
                                                                   build-lexical-reference
                                                                   build-global-reference
                                                                   build-conditional
                                                                   build-application
                                                                   global-lookup
                                                                   global-extend
                                                                   globals
                                                                   strip-annotation
                                                                   annotation-source
                                                                   annotation-expression
                                                                   annotation?
                                                                   no-source
                                                                   gensym-hook
                                                                   error-hook
                                                                   eval-hook)
                                                                  ((top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top))
                                                                  ("i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i")))))
                                                           .
                                                           each-any))))
                                                   p243))
                                               tmp241)
                                             ((lambda (tmp254)
                                                (if tmp254
                                                    (apply
                                                      (lambda ()
                                                        '#(syntax-object
                                                           '() (top) ()))
                                                      tmp254)
                                                    (syntax-error tmp240)))
                                               ($syntax-dispatch
                                                 tmp240
                                                 '()))))
                                        ($syntax-dispatch
                                          tmp240
                                          '(any . any))))
                                     p239))]
                      [quasi209 (lambda (p215 lev214)
                                  ((lambda (tmp216)
                                     ((lambda (tmp217)
                                        (if tmp217
                                            (apply
                                              (lambda (p218)
                                                (if (= lev214 '0)
                                                    p218
                                                    (quasicons205
                                                      '#(syntax-object
                                                         'unquote (top) ())
                                                      (quasi209
                                                        (cons
                                                          p218
                                                          '#(syntax-object
                                                             () (top) ()))
                                                        (- lev214 '1)))))
                                              tmp217)
                                            ((lambda (tmp219)
                                               (if tmp219
                                                   (apply
                                                     (lambda (p221 q220)
                                                       (if (= lev214 '0)
                                                           (quasilist*204
                                                             p221
                                                             (quasi209
                                                               q220
                                                               lev214))
                                                           (quasicons205
                                                             (quasicons205
                                                               '#(syntax-object
                                                                  'unquote
                                                                  (top) ())
                                                               (quasi209
                                                                 p221
                                                                 (- lev214
                                                                    '1)))
                                                             (quasi209
                                                               q220
                                                               lev214))))
                                                     tmp219)
                                                   ((lambda (tmp224)
                                                      (if tmp224
                                                          (apply
                                                            (lambda (p226
                                                                     q225)
                                                              (if (= lev214
                                                                     '0)
                                                                  (quasiappend206
                                                                    p226
                                                                    (quasi209
                                                                      q225
                                                                      lev214))
                                                                  (quasicons205
                                                                    (quasicons205
                                                                      '#(syntax-object
                                                                         'unquote-splicing
                                                                         (top)
                                                                         ())
                                                                      (quasi209
                                                                        p226
                                                                        (- lev214
                                                                           '1)))
                                                                    (quasi209
                                                                      q225
                                                                      lev214))))
                                                            tmp224)
                                                          ((lambda (tmp229)
                                                             (if tmp229
                                                                 (apply
                                                                   (lambda (p230)
                                                                     (quasicons205
                                                                       '#(syntax-object
                                                                          'quasiquote
                                                                          (top)
                                                                          ())
                                                                       (quasi209
                                                                         (cons
                                                                           p230
                                                                           '#(syntax-object
                                                                              ()
                                                                              (top)
                                                                              ()))
                                                                         (+ lev214
                                                                            '1))))
                                                                   tmp229)
                                                                 ((lambda (tmp231)
                                                                    (if tmp231
                                                                        (apply
                                                                          (lambda (p233
                                                                                   q232)
                                                                            (quasicons205
                                                                              (quasi209
                                                                                p233
                                                                                lev214)
                                                                              (quasi209
                                                                                q232
                                                                                lev214)))
                                                                          tmp231)
                                                                        ((lambda (tmp234)
                                                                           (if tmp234
                                                                               (apply
                                                                                 (lambda (x235)
                                                                                   (quasivector207
                                                                                     (vquasi208
                                                                                       x235
                                                                                       lev214)))
                                                                                 tmp234)
                                                                               ((lambda (p237)
                                                                                  (cons
                                                                                    '#(syntax-object
                                                                                       quote
                                                                                       (top)
                                                                                       ())
                                                                                    (cons
                                                                                      p237
                                                                                      '#(syntax-object
                                                                                         ()
                                                                                         (top)
                                                                                         ()))))
                                                                                 tmp216)))
                                                                          ($syntax-dispatch
                                                                            tmp216
                                                                            '#(vector
                                                                               each-any)))))
                                                                   ($syntax-dispatch
                                                                     tmp216
                                                                     '(any .
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp216
                                                              '(#(free-id
                                                                  #(syntax-object
                                                                    quasiquote
                                                                    (top)
                                                                    (#(rib
                                                                       ()
                                                                       ()
                                                                       ())
                                                                      #(rib
                                                                        (p lev)
                                                                        ((top)
                                                                          (top))
                                                                        ("i" "i"))
                                                                      #(rib
                                                                        (quasi
                                                                          vquasi
                                                                          quasivector
                                                                          quasiappend
                                                                          quasicons
                                                                          quasilist*)
                                                                        ((top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top)
                                                                          (top))
                                                                        ("i" "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"
                                                                             "i"))
                                                                      #(rib
                                                                        (invalid-ids-error
                                                                         distinct-bound-ids?
                                                                         valid-bound-ids?
                                                                         bound-id-member?
                                                                         bound-id=?
                                                                         free-id=?
                                                                         label->binding
                                                                         id->label
                                                                         gen-var
                                                                         id->sym
                                                                         id?
                                                                         eval-transformer
                                                                         displaced-lexical-error
                                                                         extend-var-env*
                                                                         extend-env*
                                                                         extend-env
                                                                         null-env
                                                                         binding-value
                                                                         binding-type
                                                                         make-binding
                                                                         gen-label
                                                                         make-full-rib
                                                                         extend-rib!
                                                                         make-empty-rib
                                                                         set-rib-label*!
                                                                         set-rib-mark**!
                                                                         set-rib-sym*!
                                                                         rib-label*
                                                                         rib-mark**
                                                                         rib-sym*
                                                                         rib?
                                                                         make-rib
                                                                         syntax-object
                                                                         join-wraps
                                                                         add-subst
                                                                         top-subst*
                                                                         same-marks?
                                                                         add-mark
                                                                         anti-mark
                                                                         gen-mark
                                                                         top-marked?
                                                                         top-mark*
                                                                         unannotate
                                                                         source
                                                                         strip
                                                                         set-syntax-object-subst*!
                                                                         set-syntax-object-mark*!
                                                                         set-syntax-object-expression!
                                                                         syntax-object-subst*
                                                                         syntax-object-mark*
                                                                         syntax-object-expression
                                                                         syntax-object?
                                                                         make-syntax-object
                                                                         let-values
                                                                         define-structure
                                                                         andmap
                                                                         self-evaluating?
                                                                         build-lexical-var
                                                                         build-letrec*
                                                                         build-letrec
                                                                         build-sequence
                                                                         build-data
                                                                         build-primref
                                                                         build-lambda
                                                                         build-global-assignment
                                                                         build-lexical-assignment
                                                                         build-lexical-reference
                                                                         build-global-reference
                                                                         build-conditional
                                                                         build-application
                                                                         global-lookup
                                                                         global-extend
                                                                         globals
                                                                         strip-annotation
                                                                         annotation-source
                                                                         annotation-expression
                                                                         annotation?
                                                                         no-source
                                                                         gensym-hook
                                                                         error-hook
                                                                         eval-hook)
                                                                        ((top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top)
                                                                         (top))
                                                                        ("i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i"
                                                                         "i")))))
                                                                 any)))))
                                                     ($syntax-dispatch
                                                       tmp216
                                                       '((#(free-id
                                                            #(syntax-object
                                                              unquote-splicing
                                                              (top)
                                                              (#(rib () ()
                                                                 ())
                                                                #(rib
                                                                  (p lev)
                                                                  ((top)
                                                                    (top))
                                                                  ("i" "i"))
                                                                #(rib
                                                                  (quasi
                                                                    vquasi
                                                                    quasivector
                                                                    quasiappend
                                                                    quasicons
                                                                    quasilist*)
                                                                  ((top)
                                                                    (top)
                                                                    (top)
                                                                    (top)
                                                                    (top)
                                                                    (top))
                                                                  ("i" "i"
                                                                       "i"
                                                                       "i"
                                                                       "i"
                                                                       "i"))
                                                                #(rib
                                                                  (invalid-ids-error
                                                                   distinct-bound-ids?
                                                                   valid-bound-ids?
                                                                   bound-id-member?
                                                                   bound-id=?
                                                                   free-id=?
                                                                   label->binding
                                                                   id->label
                                                                   gen-var
                                                                   id->sym
                                                                   id?
                                                                   eval-transformer
                                                                   displaced-lexical-error
                                                                   extend-var-env*
                                                                   extend-env*
                                                                   extend-env
                                                                   null-env
                                                                   binding-value
                                                                   binding-type
                                                                   make-binding
                                                                   gen-label
                                                                   make-full-rib
                                                                   extend-rib!
                                                                   make-empty-rib
                                                                   set-rib-label*!
                                                                   set-rib-mark**!
                                                                   set-rib-sym*!
                                                                   rib-label*
                                                                   rib-mark**
                                                                   rib-sym*
                                                                   rib?
                                                                   make-rib
                                                                   syntax-object
                                                                   join-wraps
                                                                   add-subst
                                                                   top-subst*
                                                                   same-marks?
                                                                   add-mark
                                                                   anti-mark
                                                                   gen-mark
                                                                   top-marked?
                                                                   top-mark*
                                                                   unannotate
                                                                   source
                                                                   strip
                                                                   set-syntax-object-subst*!
                                                                   set-syntax-object-mark*!
                                                                   set-syntax-object-expression!
                                                                   syntax-object-subst*
                                                                   syntax-object-mark*
                                                                   syntax-object-expression
                                                                   syntax-object?
                                                                   make-syntax-object
                                                                   let-values
                                                                   define-structure
                                                                   andmap
                                                                   self-evaluating?
                                                                   build-lexical-var
                                                                   build-letrec*
                                                                   build-letrec
                                                                   build-sequence
                                                                   build-data
                                                                   build-primref
                                                                   build-lambda
                                                                   build-global-assignment
                                                                   build-lexical-assignment
                                                                   build-lexical-reference
                                                                   build-global-reference
                                                                   build-conditional
                                                                   build-application
                                                                   global-lookup
                                                                   global-extend
                                                                   globals
                                                                   strip-annotation
                                                                   annotation-source
                                                                   annotation-expression
                                                                   annotation?
                                                                   no-source
                                                                   gensym-hook
                                                                   error-hook
                                                                   eval-hook)
                                                                  ((top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top)
                                                                   (top))
                                                                  ("i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i" "i"
                                                                   "i")))))
                                                           .
                                                           each-any)
                                                          .
                                                          any)))))
                                              ($syntax-dispatch
                                                tmp216
                                                '((#(free-id
                                                     #(syntax-object
                                                       unquote (top)
                                                       (#(rib () () ())
                                                         #(rib (p lev)
                                                           ((top) (top))
                                                           ("i" "i"))
                                                         #(rib
                                                           (quasi vquasi
                                                             quasivector
                                                             quasiappend
                                                             quasicons
                                                             quasilist*)
                                                           ((top) (top)
                                                             (top) (top)
                                                             (top) (top))
                                                           ("i" "i" "i" "i"
                                                                "i" "i"))
                                                         #(rib
                                                           (invalid-ids-error
                                                            distinct-bound-ids?
                                                            valid-bound-ids?
                                                            bound-id-member?
                                                            bound-id=?
                                                            free-id=?
                                                            label->binding
                                                            id->label
                                                            gen-var id->sym
                                                            id?
                                                            eval-transformer
                                                            displaced-lexical-error
                                                            extend-var-env*
                                                            extend-env*
                                                            extend-env
                                                            null-env
                                                            binding-value
                                                            binding-type
                                                            make-binding
                                                            gen-label
                                                            make-full-rib
                                                            extend-rib!
                                                            make-empty-rib
                                                            set-rib-label*!
                                                            set-rib-mark**!
                                                            set-rib-sym*!
                                                            rib-label*
                                                            rib-mark**
                                                            rib-sym* rib?
                                                            make-rib
                                                            syntax-object
                                                            join-wraps
                                                            add-subst
                                                            top-subst*
                                                            same-marks?
                                                            add-mark
                                                            anti-mark
                                                            gen-mark
                                                            top-marked?
                                                            top-mark*
                                                            unannotate
                                                            source strip
                                                            set-syntax-object-subst*!
                                                            set-syntax-object-mark*!
                                                            set-syntax-object-expression!
                                                            syntax-object-subst*
                                                            syntax-object-mark*
                                                            syntax-object-expression
                                                            syntax-object?
                                                            make-syntax-object
                                                            let-values
                                                            define-structure
                                                            andmap
                                                            self-evaluating?
                                                            build-lexical-var
                                                            build-letrec*
                                                            build-letrec
                                                            build-sequence
                                                            build-data
                                                            build-primref
                                                            build-lambda
                                                            build-global-assignment
                                                            build-lexical-assignment
                                                            build-lexical-reference
                                                            build-global-reference
                                                            build-conditional
                                                            build-application
                                                            global-lookup
                                                            global-extend
                                                            globals
                                                            strip-annotation
                                                            annotation-source
                                                            annotation-expression
                                                            annotation?
                                                            no-source
                                                            gensym-hook
                                                            error-hook
                                                            eval-hook)
                                                           ((top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top) (top)
                                                            (top))
                                                           ("i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i" "i" "i" "i"
                                                            "i")))))
                                                    .
                                                    each-any)
                                                   .
                                                   any)))))
                                       ($syntax-dispatch
                                         tmp216
                                         '(#(free-id
                                             #(syntax-object unquote (top)
                                               (#(rib () () ())
                                                 #(rib (p lev)
                                                   ((top) (top)) ("i" "i"))
                                                 #(rib
                                                   (quasi vquasi
                                                     quasivector
                                                     quasiappend quasicons
                                                     quasilist*)
                                                   ((top) (top) (top) (top)
                                                     (top) (top))
                                                   ("i" "i" "i" "i" "i"
                                                        "i"))
                                                 #(rib
                                                   (invalid-ids-error
                                                    distinct-bound-ids?
                                                    valid-bound-ids?
                                                    bound-id-member?
                                                    bound-id=? free-id=?
                                                    label->binding
                                                    id->label gen-var
                                                    id->sym id?
                                                    eval-transformer
                                                    displaced-lexical-error
                                                    extend-var-env*
                                                    extend-env* extend-env
                                                    null-env binding-value
                                                    binding-type
                                                    make-binding gen-label
                                                    make-full-rib
                                                    extend-rib!
                                                    make-empty-rib
                                                    set-rib-label*!
                                                    set-rib-mark**!
                                                    set-rib-sym*!
                                                    rib-label* rib-mark**
                                                    rib-sym* rib? make-rib
                                                    syntax-object
                                                    join-wraps add-subst
                                                    top-subst* same-marks?
                                                    add-mark anti-mark
                                                    gen-mark top-marked?
                                                    top-mark* unannotate
                                                    source strip
                                                    set-syntax-object-subst*!
                                                    set-syntax-object-mark*!
                                                    set-syntax-object-expression!
                                                    syntax-object-subst*
                                                    syntax-object-mark*
                                                    syntax-object-expression
                                                    syntax-object?
                                                    make-syntax-object
                                                    let-values
                                                    define-structure andmap
                                                    self-evaluating?
                                                    build-lexical-var
                                                    build-letrec*
                                                    build-letrec
                                                    build-sequence
                                                    build-data
                                                    build-primref
                                                    build-lambda
                                                    build-global-assignment
                                                    build-lexical-assignment
                                                    build-lexical-reference
                                                    build-global-reference
                                                    build-conditional
                                                    build-application
                                                    global-lookup
                                                    global-extend globals
                                                    strip-annotation
                                                    annotation-source
                                                    annotation-expression
                                                    annotation? no-source
                                                    gensym-hook error-hook
                                                    eval-hook)
                                                   ((top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top) (top) (top) (top)
                                                    (top))
                                                   ("i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i" "i" "i" "i"
                                                    "i" "i" "i")))))
                                            any))))
                                    p215))])
              (lambda (x210)
                ((lambda (tmp211)
                   ((lambda (tmp212)
                      (if tmp212
                          (apply (lambda (e213) (quasi209 e213 '0)) tmp212)
                          (syntax-error tmp211)))
                     ($syntax-dispatch tmp211 '(_ any))))
                  x210))))))
       (global-extend9
         'macro
         'unquote
         (lambda (x200)
           ((lambda (tmp201)
              ((lambda (tmp202)
                 (if tmp202
                     (apply
                       (lambda (e203)
                         (syntax-error
                           x200
                           '"expression not valid outside of quasiquote"))
                       tmp202)
                     (syntax-error tmp201)))
                ($syntax-dispatch tmp201 '(_ . each-any))))
             x200)))
       (global-extend9
         'macro
         'unquote-splicing
         (lambda (x196)
           ((lambda (tmp197)
              ((lambda (tmp198)
                 (if tmp198
                     (apply
                       (lambda (e199)
                         (syntax-error
                           x196
                           '"expression not valid outside of quasiquote"))
                       tmp198)
                     (syntax-error tmp197)))
                ($syntax-dispatch tmp197 '(_ . each-any))))
             x196)))
       (global-extend9
         'macro
         'case
         (lambda (x164)
           ((lambda (tmp165)
              ((lambda (tmp166)
                 (if tmp166
                     (apply
                       (lambda (dummy173 e0172 k171 e1170 e2169 else-e1168
                                else-e2167)
                         (cons
                           '#(syntax-object let (top) ())
                           (cons
                             (cons
                               (cons
                                 '#(syntax-object t (top) ())
                                 (cons
                                   e0172
                                   '#(syntax-object () (top) ())))
                               '#(syntax-object () (top) ()))
                             (cons
                               (cons
                                 '#(syntax-object cond (top) ())
                                 (append
                                   (map (lambda (tmp178 tmp177 tmp175)
                                          (cons
                                            (cons
                                              '#(syntax-object memv (top)
                                                 ())
                                              (cons
                                                '#(syntax-object t (top)
                                                   ())
                                                (cons
                                                  (cons
                                                    '#(syntax-object quote
                                                       (top) ())
                                                    (cons
                                                      tmp175
                                                      '#(syntax-object ()
                                                         (top) ())))
                                                  '#(syntax-object () (top)
                                                     ()))))
                                            (cons tmp177 tmp178)))
                                        e2169
                                        e1170
                                        k171)
                                   (cons
                                     (cons
                                       '#(syntax-object else (top) ())
                                       (cons else-e1168 else-e2167))
                                     '#(syntax-object () (top) ()))))
                               '#(syntax-object () (top) ())))))
                       tmp166)
                     ((lambda (tmp180)
                        (if tmp180
                            (apply
                              (lambda (dummy188 e0187 ka186 e1a185 e2a184
                                       kb183 e1b182 e2b181)
                                (cons
                                  '#(syntax-object let (top) ())
                                  (cons
                                    (cons
                                      (cons
                                        '#(syntax-object t (top) ())
                                        (cons
                                          e0187
                                          '#(syntax-object () (top) ())))
                                      '#(syntax-object () (top) ()))
                                    (cons
                                      (cons
                                        '#(syntax-object cond (top) ())
                                        (cons
                                          (cons
                                            (cons
                                              '#(syntax-object memv (top)
                                                 ())
                                              (cons
                                                '#(syntax-object t (top)
                                                   ())
                                                (cons
                                                  (cons
                                                    '#(syntax-object quote
                                                       (top) ())
                                                    (cons
                                                      ka186
                                                      '#(syntax-object ()
                                                         (top) ())))
                                                  '#(syntax-object () (top)
                                                     ()))))
                                            (cons e1a185 e2a184))
                                          (map (lambda (tmp194 tmp193
                                                        tmp191)
                                                 (cons
                                                   (cons
                                                     '#(syntax-object memv
                                                        (top) ())
                                                     (cons
                                                       '#(syntax-object t
                                                          (top) ())
                                                       (cons
                                                         (cons
                                                           '#(syntax-object
                                                              quote (top)
                                                              ())
                                                           (cons
                                                             tmp191
                                                             '#(syntax-object
                                                                () (top)
                                                                ())))
                                                         '#(syntax-object
                                                            () (top) ()))))
                                                   (cons tmp193 tmp194)))
                                               e2b181
                                               e1b182
                                               kb183)))
                                      '#(syntax-object () (top) ())))))
                              tmp180)
                            (syntax-error tmp165)))
                       ($syntax-dispatch
                         tmp165
                         '(any any
                               (each-any any . each-any)
                               .
                               #(each (each-any any . each-any)))))))
                ($syntax-dispatch
                  tmp165
                  '(any any
                        .
                        #(each+ (each-any any . each-any)
                          ((#(free-id
                              #(syntax-object else (top)
                                (#(rib () () ())
                                  #(rib (x) (("m" top)) ("i"))
                                  #(rib
                                    (invalid-ids-error distinct-bound-ids?
                                     valid-bound-ids? bound-id-member?
                                     bound-id=? free-id=? label->binding
                                     id->label gen-var id->sym id?
                                     eval-transformer
                                     displaced-lexical-error
                                     extend-var-env* extend-env* extend-env
                                     null-env binding-value binding-type
                                     make-binding gen-label make-full-rib
                                     extend-rib! make-empty-rib
                                     set-rib-label*! set-rib-mark**!
                                     set-rib-sym*! rib-label* rib-mark**
                                     rib-sym* rib? make-rib syntax-object
                                     join-wraps add-subst top-subst*
                                     same-marks? add-mark anti-mark
                                     gen-mark top-marked? top-mark*
                                     unannotate source strip
                                     set-syntax-object-subst*!
                                     set-syntax-object-mark*!
                                     set-syntax-object-expression!
                                     syntax-object-subst*
                                     syntax-object-mark*
                                     syntax-object-expression
                                     syntax-object? make-syntax-object
                                     let-values define-structure andmap
                                     self-evaluating? build-lexical-var
                                     build-letrec* build-letrec
                                     build-sequence build-data
                                     build-primref build-lambda
                                     build-global-assignment
                                     build-lexical-assignment
                                     build-lexical-reference
                                     build-global-reference
                                     build-conditional build-application
                                     global-lookup global-extend globals
                                     strip-annotation annotation-source
                                     annotation-expression annotation?
                                     no-source gensym-hook error-hook
                                     eval-hook)
                                    ((top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top) (top) (top) (top)
                                     (top) (top) (top))
                                    ("i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i")))))
                             any
                             .
                             each-any))
                          ())))))
             x164)))
       (global-extend9
         'macro
         'identifier-syntax
         (lambda (x146)
           ((lambda (tmp147)
              ((lambda (tmp148)
                 (if tmp148
                     (apply
                       (lambda (dummy150 e149)
                         (cons
                           '#(syntax-object lambda (top) ())
                           (cons
                             '#(syntax-object (x) (top) ())
                             (cons
                               (cons
                                 '#(syntax-object syntax-case (top) ())
                                 (cons
                                   '#(syntax-object x (top) ())
                                   (cons
                                     '#(syntax-object () (top) ())
                                     (cons
                                       (cons
                                         '#(syntax-object id (top) ())
                                         (cons
                                           '#(syntax-object
                                              (identifier? #'id) (top) ())
                                           (cons
                                             (cons
                                               '#(syntax-object syntax
                                                  (top) ())
                                               (cons
                                                 e149
                                                 '#(syntax-object () (top)
                                                    ())))
                                             '#(syntax-object () (top)
                                                ()))))
                                       (cons
                                         (cons
                                           '(#(syntax-object id (top) ())
                                              #(syntax-object x (top) ())
                                              #(syntax-object ... (top) ())
                                              .
                                              #(syntax-object () (top) ()))
                                           (cons
                                             (cons
                                               '#(syntax-object syntax
                                                  (top) ())
                                               (cons
                                                 (cons
                                                   e149
                                                   '(#(syntax-object x
                                                       (top) ())
                                                      #(syntax-object ...
                                                        (top) ())
                                                      .
                                                      #(syntax-object ()
                                                        (top) ())))
                                                 '#(syntax-object () (top)
                                                    ())))
                                             '#(syntax-object () (top)
                                                ())))
                                         '#(syntax-object () (top) ()))))))
                               '#(syntax-object () (top) ())))))
                       tmp148)
                     ((lambda (tmp151)
                        (if (if tmp151
                                (apply
                                  (lambda (dummy157 id156 exp1155 var154
                                           rhs153 exp2152)
                                    (if (identifier? id156)
                                        (identifier? var154)
                                        '#f))
                                  tmp151)
                                '#f)
                            (apply
                              (lambda (dummy163 id162 exp1161 var160 rhs159
                                       exp2158)
                                (cons
                                  '#(syntax-object
                                     make-variable-transformer (top) ())
                                  (cons
                                    (cons
                                      '#(syntax-object lambda (top) ())
                                      (cons
                                        '#(syntax-object (x) (top) ())
                                        (cons
                                          (cons
                                            '#(syntax-object syntax-case
                                               (top) ())
                                            (cons
                                              '#(syntax-object x (top) ())
                                              (cons
                                                '#(syntax-object (set!)
                                                   (top) ())
                                                (cons
                                                  (cons
                                                    (cons
                                                      '#(syntax-object set!
                                                         (top) ())
                                                      (cons
                                                        var160
                                                        (cons
                                                          rhs159
                                                          '#(syntax-object
                                                             () (top)
                                                             ()))))
                                                    (cons
                                                      (cons
                                                        '#(syntax-object
                                                           syntax (top) ())
                                                        (cons
                                                          exp2158
                                                          '#(syntax-object
                                                             () (top) ())))
                                                      '#(syntax-object ()
                                                         (top) ())))
                                                  (cons
                                                    (cons
                                                      (cons
                                                        id162
                                                        '(#(syntax-object x
                                                            (top) ())
                                                           #(syntax-object
                                                             ... (top) ())
                                                           .
                                                           #(syntax-object
                                                             () (top) ())))
                                                      (cons
                                                        (cons
                                                          '#(syntax-object
                                                             syntax (top)
                                                             ())
                                                          (cons
                                                            (cons
                                                              exp1161
                                                              '(#(syntax-object
                                                                  x (top)
                                                                  ())
                                                                 #(syntax-object
                                                                   ...
                                                                   (top)
                                                                   ())
                                                                 .
                                                                 #(syntax-object
                                                                   () (top)
                                                                   ())))
                                                            '#(syntax-object
                                                               () (top)
                                                               ())))
                                                        '#(syntax-object ()
                                                           (top) ())))
                                                    (cons
                                                      (cons
                                                        id162
                                                        (cons
                                                          (cons
                                                            '#(syntax-object
                                                               identifier?
                                                               (top) ())
                                                            (cons
                                                              (cons
                                                                '#(syntax-object
                                                                   syntax
                                                                   (top)
                                                                   ())
                                                                (cons
                                                                  id162
                                                                  '#(syntax-object
                                                                     ()
                                                                     (top)
                                                                     ())))
                                                              '#(syntax-object
                                                                 () (top)
                                                                 ())))
                                                          (cons
                                                            (cons
                                                              '#(syntax-object
                                                                 syntax
                                                                 (top) ())
                                                              (cons
                                                                exp1161
                                                                '#(syntax-object
                                                                   () (top)
                                                                   ())))
                                                            '#(syntax-object
                                                               () (top)
                                                               ()))))
                                                      '#(syntax-object ()
                                                         (top) ())))))))
                                          '#(syntax-object () (top) ()))))
                                    '#(syntax-object () (top) ()))))
                              tmp151)
                            (syntax-error tmp147)))
                       ($syntax-dispatch
                         tmp147
                         '(any (any any)
                               ((#(free-id
                                   #(syntax-object set! (top)
                                     (#(rib () () ())
                                       #(rib (x) (("m" top)) ("i"))
                                       #(rib
                                         (invalid-ids-error
                                          distinct-bound-ids?
                                          valid-bound-ids? bound-id-member?
                                          bound-id=? free-id=?
                                          label->binding id->label gen-var
                                          id->sym id? eval-transformer
                                          displaced-lexical-error
                                          extend-var-env* extend-env*
                                          extend-env null-env binding-value
                                          binding-type make-binding
                                          gen-label make-full-rib
                                          extend-rib! make-empty-rib
                                          set-rib-label*! set-rib-mark**!
                                          set-rib-sym*! rib-label*
                                          rib-mark** rib-sym* rib? make-rib
                                          syntax-object join-wraps
                                          add-subst top-subst* same-marks?
                                          add-mark anti-mark gen-mark
                                          top-marked? top-mark* unannotate
                                          source strip
                                          set-syntax-object-subst*!
                                          set-syntax-object-mark*!
                                          set-syntax-object-expression!
                                          syntax-object-subst*
                                          syntax-object-mark*
                                          syntax-object-expression
                                          syntax-object? make-syntax-object
                                          let-values define-structure
                                          andmap self-evaluating?
                                          build-lexical-var build-letrec*
                                          build-letrec build-sequence
                                          build-data build-primref
                                          build-lambda
                                          build-global-assignment
                                          build-lexical-assignment
                                          build-lexical-reference
                                          build-global-reference
                                          build-conditional
                                          build-application global-lookup
                                          global-extend globals
                                          strip-annotation
                                          annotation-source
                                          annotation-expression annotation?
                                          no-source gensym-hook error-hook
                                          eval-hook)
                                         ((top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top) (top) (top) (top) (top)
                                          (top))
                                         ("i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i")))))
                                  any
                                  any)
                                 any))))))
                ($syntax-dispatch tmp147 '(any any))))
             x146)))
       (global-extend9
         'macro
         'when
         (lambda (x138)
           ((lambda (tmp139)
              ((lambda (tmp140)
                 (if tmp140
                     (apply
                       (lambda (dummy144 test143 e1142 e2141)
                         (cons
                           '#(syntax-object if (top) ())
                           (cons
                             test143
                             (cons
                               (cons
                                 '#(syntax-object begin (top) ())
                                 (cons e1142 e2141))
                               '#(syntax-object () (top) ())))))
                       tmp140)
                     (syntax-error tmp139)))
                ($syntax-dispatch tmp139 '(any any any . each-any))))
             x138)))
       (global-extend9
         'macro
         'unless
         (lambda (x130)
           ((lambda (tmp131)
              ((lambda (tmp132)
                 (if tmp132
                     (apply
                       (lambda (dummy136 test135 e1134 e2133)
                         (cons
                           '#(syntax-object when (top) ())
                           (cons
                             (cons
                               '#(syntax-object not (top) ())
                               (cons
                                 test135
                                 '#(syntax-object () (top) ())))
                             (cons
                               (cons
                                 '#(syntax-object begin (top) ())
                                 (cons e1134 e2133))
                               '#(syntax-object () (top) ())))))
                       tmp132)
                     (syntax-error tmp131)))
                ($syntax-dispatch tmp131 '(any any any . each-any))))
             x130)))))))
