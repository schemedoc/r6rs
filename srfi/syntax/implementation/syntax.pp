;;; syntax.pp
;;; automatically generated from syntax.ss
;;; Thu May 11 13:16:02 2006
;;; see copyright notice in syntax.ss

((lambda ()
   (letrec* ([eval-hook0 (lambda (x1268) (eval x1268))]
             [error-hook1 (lambda (who1267 why1266 what1265)
                            (error who1267 '"~a ~s" why1266 what1265))]
             [gensym-hook2 gensym]
             [no-source3 '#f]
             [annotation?4 (lambda (x1264) '#f)]
             [annotation-expression5 (lambda (x1263) x1263)]
             [annotation-source6 (lambda (x1262) no-source3)]
             [strip-annotation7 (lambda (x1261) x1261)]
             [globals8 '()]
             [global-extend9 (lambda (type1260 sym1259 value1258)
                               (set! globals8
                                 (cons
                                   (cons
                                     sym1259
                                     (make-binding109 type1260 value1258))
                                   globals8)))]
             [global-lookup10 (lambda (sym1256)
                                ((lambda (t1257)
                                   (if t1257
                                       (cdr t1257)
                                       (cons 'global sym1256)))
                                  (assq sym1256 globals8)))]
             [build-application11 (lambda (src1255 proc-expr1254
                                           arg-expr*1253)
                                    (cons proc-expr1254 arg-expr*1253))]
             [build-global-reference25 (lambda (src1252 var1251)
                                         var1251)]
             [build-lexical-reference26 (lambda (src1250 var1249)
                                          var1249)]
             [build-lexical-assignment27 (lambda (src1248 var1247
                                                  expr1246)
                                           (cons
                                             'set!
                                             (cons
                                               var1247
                                               (cons expr1246 '()))))]
             [build-global-assignment28 (lambda (src1245 var1244
                                                 expr1243)
                                          (cons
                                            'set!
                                            (cons
                                              var1244
                                              (cons expr1243 '()))))]
             [build-lambda29 (lambda (src1239 var*1238 rest?1237
                                      expr1236)
                               (cons
                                 'lambda
                                 (cons
                                   (if rest?1237
                                       ((letrec ([f1240 (lambda (var1242
                                                                 var*1241)
                                                          (if (pair?
                                                                var*1241)
                                                              (cons
                                                                var1242
                                                                (f1240
                                                                  (car var*1241)
                                                                  (cdr var*1241)))
                                                              var1242))])
                                          f1240)
                                         (car var*1238)
                                         (cdr var*1238))
                                       var*1238)
                                   (cons expr1236 '()))))]
             [build-primref30 (lambda (src1235 name1234) name1234)]
             [build-data31 (lambda (src1233 datum1232)
                             (cons 'quote (cons datum1232 '())))]
             [build-sequence32 (lambda (src1229 expr*1228)
                                 ((letrec ([loop1230 (lambda (expr*1231)
                                                       (if (null?
                                                             (cdr expr*1231))
                                                           (car expr*1231)
                                                           (cons
                                                             'begin
                                                             (append
                                                               expr*1231
                                                               '()))))])
                                    loop1230)
                                   expr*1228))]
             [build-letrec33 (lambda (src1227 var*1226 rhs-expr*1225
                                      body-expr1224)
                               (if (null? var*1226)
                                   body-expr1224
                                   (cons
                                     'letrec
                                     (cons
                                       (map list var*1226 rhs-expr*1225)
                                       (cons body-expr1224 '())))))]
             [build-letrec*34 (lambda (src1223 var*1222 rhs-expr*1221
                                       body-expr1220)
                                (if (null? var*1222)
                                    body-expr1220
                                    (cons
                                      'letrec*
                                      (cons
                                        (map list var*1222 rhs-expr*1221)
                                        (cons body-expr1220 '())))))]
             [build-lexical-var35 (lambda (src1219 id1218) (gensym))]
             [self-evaluating?36 (lambda (x1214)
                                   ((lambda (t1215)
                                      (if t1215
                                          t1215
                                          ((lambda (t1216)
                                             (if t1216
                                                 t1216
                                                 ((lambda (t1217)
                                                    (if t1217
                                                        t1217
                                                        (char? x1214)))
                                                   (string? x1214))))
                                            (number? x1214))))
                                     (boolean? x1214)))]
             [andmap37 (lambda (f1208 ls1207 . more1206)
                         ((letrec ([andmap1209 (lambda (ls1212 more1211
                                                        a1210)
                                                 (if (null? ls1212)
                                                     a1210
                                                     ((lambda (a1213)
                                                        (if a1213
                                                            (andmap1209
                                                              (cdr ls1212)
                                                              (map cdr
                                                                   more1211)
                                                              a1213)
                                                            '#f))
                                                       (apply
                                                         f1208
                                                         (car ls1212)
                                                         (map car
                                                              more1211)))))])
                            andmap1209)
                           ls1207
                           more1206
                           '#t))]
             [make-syntax-object77 (lambda (expression1205 mark*1204
                                            subst*1203)
                                     (vector
                                       'syntax-object
                                       expression1205
                                       mark*1204
                                       subst*1203))]
             [syntax-object?78 (lambda (x1202)
                                 (if (vector? x1202)
                                     (if (= (vector-length x1202) '4)
                                         (eq? (vector-ref x1202 '0)
                                              'syntax-object)
                                         '#f)
                                     '#f))]
             [syntax-object-expression79 (lambda (x1201)
                                           (vector-ref x1201 '1))]
             [syntax-object-mark*80 (lambda (x1200)
                                      (vector-ref x1200 '2))]
             [syntax-object-subst*81 (lambda (x1199)
                                       (vector-ref x1199 '3))]
             [set-syntax-object-expression!82 (lambda (x1198 update1197)
                                                (vector-set!
                                                  x1198
                                                  '1
                                                  update1197))]
             [set-syntax-object-mark*!83 (lambda (x1196 update1195)
                                           (vector-set!
                                             x1196
                                             '2
                                             update1195))]
             [set-syntax-object-subst*!84 (lambda (x1194 update1193)
                                            (vector-set!
                                              x1194
                                              '3
                                              update1193))]
             [strip85 (lambda (x1186 m*1185)
                        (if (top-marked?89 m*1185)
                            (strip-annotation7 x1186)
                            ((letrec ([f1187 (lambda (x1188)
                                               (if (syntax-object?78 x1188)
                                                   (strip85
                                                     (syntax-object-expression79
                                                       x1188)
                                                     (syntax-object-mark*80
                                                       x1188))
                                                   (if (pair? x1188)
                                                       ((lambda (a1190
                                                                 d1189)
                                                          (if (if (eq? a1190
                                                                       (car x1188))
                                                                  (eq? d1189
                                                                       (cdr x1188))
                                                                  '#f)
                                                              x1188
                                                              (cons
                                                                a1190
                                                                d1189)))
                                                         (f1187
                                                           (car x1188))
                                                         (f1187
                                                           (cdr x1188)))
                                                       (if (vector? x1188)
                                                           ((lambda (old1191)
                                                              ((lambda (new1192)
                                                                 (if (andmap37
                                                                       eq?
                                                                       old1191
                                                                       new1192)
                                                                     x1188
                                                                     (list->vector
                                                                       new1192)))
                                                                (map f1187
                                                                     old1191)))
                                                             (vector->list
                                                               x1188))
                                                           x1188))))])
                               f1187)
                              x1186)))]
             [syn->src86 (lambda (e1183)
                           ((lambda (x1184)
                              (if (annotation?4 x1184)
                                  (annotation-source6 x1184)
                                  no-source3))
                             (syntax-object-expression79 e1183)))]
             [unannotate87 (lambda (x1182)
                             (if (annotation?4 x1182)
                                 (annotation-expression5 x1182)
                                 x1182))]
             [top-mark*88 '(top)]
             [top-marked?89 (lambda (m*1181)
                              (memq (car top-mark*88) m*1181))]
             [gen-mark90 (lambda () (string '#\m))]
             [the-anti-mark91 '#f]
             [anti-mark92 (lambda (e1180)
                            (make-syntax-object77
                              (syntax-object-expression79 e1180)
                              (cons
                                the-anti-mark91
                                (syntax-object-mark*80 e1180))
                              (cons
                                'shift
                                (syntax-object-subst*81 e1180))))]
             [add-mark93 (lambda (m1178 e1177)
                           ((lambda (mark*1179)
                              (if (if (pair? mark*1179)
                                      (eq? (car mark*1179) the-anti-mark91)
                                      '#f)
                                  (make-syntax-object77
                                    (syntax-object-expression79 e1177)
                                    (cdr mark*1179)
                                    (cdr (syntax-object-subst*81 e1177)))
                                  (make-syntax-object77
                                    (syntax-object-expression79 e1177)
                                    (cons m1178 mark*1179)
                                    (cons
                                      'shift
                                      (syntax-object-subst*81 e1177)))))
                             (syntax-object-mark*80 e1177)))]
             [same-marks?94 (lambda (x1175 y1174)
                              ((lambda (t1176)
                                 (if t1176
                                     t1176
                                     (if (if (not (null? x1175))
                                             (not (null? y1174))
                                             '#f)
                                         (if (eq? (car x1175) (car y1174))
                                             (same-marks?94
                                               (cdr x1175)
                                               (cdr y1174))
                                             '#f)
                                         '#f)))
                                (eq? x1175 y1174)))]
             [top-subst*95 '()]
             [add-subst96 (lambda (subst1173 e1172)
                            (if subst1173
                                (make-syntax-object77
                                  (syntax-object-expression79 e1172)
                                  (syntax-object-mark*80 e1172)
                                  (cons
                                    subst1173
                                    (syntax-object-subst*81 e1172)))
                                e1172))]
             [make-rib97 (lambda (sym*1171 mark**1170 label*1169)
                           (vector 'rib sym*1171 mark**1170 label*1169))]
             [rib?98 (lambda (x1168)
                       (if (vector? x1168)
                           (if (= (vector-length x1168) '4)
                               (eq? (vector-ref x1168 '0) 'rib)
                               '#f)
                           '#f))]
             [rib-sym*99 (lambda (x1167) (vector-ref x1167 '1))]
             [rib-mark**100 (lambda (x1166) (vector-ref x1166 '2))]
             [rib-label*101 (lambda (x1165) (vector-ref x1165 '3))]
             [set-rib-sym*!102 (lambda (x1164 update1163)
                                 (vector-set! x1164 '1 update1163))]
             [set-rib-mark**!103 (lambda (x1162 update1161)
                                   (vector-set! x1162 '2 update1161))]
             [set-rib-label*!104 (lambda (x1160 update1159)
                                   (vector-set! x1160 '3 update1159))]
             [make-empty-rib105 (lambda () (make-rib97 '() '() '()))]
             [extend-rib!106 (lambda (rib1158 id1157 label1156)
                               (begin
                                 (set-rib-sym*!102
                                   rib1158
                                   (cons
                                     (id->sym119 id1157)
                                     (rib-sym*99 rib1158)))
                                 (set-rib-mark**!103
                                   rib1158
                                   (cons
                                     (syntax-object-mark*80 id1157)
                                     (rib-mark**100 rib1158)))
                                 (set-rib-label*!104
                                   rib1158
                                   (cons
                                     label1156
                                     (rib-label*101 rib1158)))))]
             [make-full-rib107 (lambda (id*1149 label*1148)
                                 (if (not (null? id*1149))
                                     (call-with-values
                                       (lambda ()
                                         ((letrec ([f1152 (lambda (id*1153)
                                                            (if (null?
                                                                  id*1153)
                                                                (values
                                                                  '()
                                                                  '())
                                                                (call-with-values
                                                                  (lambda ()
                                                                    (f1152
                                                                      (cdr id*1153)))
                                                                  (lambda (sym*1155
                                                                           mark**1154)
                                                                    (values
                                                                      (cons
                                                                        (id->sym119
                                                                          (car id*1153))
                                                                        sym*1155)
                                                                      (cons
                                                                        (syntax-object-mark*80
                                                                          (car id*1153))
                                                                        mark**1154))))))])
                                            f1152)
                                           id*1149))
                                       (lambda (sym*1151 mark**1150)
                                         (make-rib97
                                           sym*1151
                                           mark**1150
                                           label*1148)))
                                     '#f))]
             [gen-label108 (lambda () (string '#\i))]
             [make-binding109 cons]
             [binding-type110 car]
             [binding-value111 cdr]
             [null-env112 '()]
             [extend-env113 (lambda (label1147 binding1146 r1145)
                              (cons (cons label1147 binding1146) r1145))]
             [extend-env*114 (lambda (label*1144 binding*1143 r1142)
                               (if (null? label*1144)
                                   r1142
                                   (extend-env*114
                                     (cdr label*1144)
                                     (cdr binding*1143)
                                     (extend-env113
                                       (car label*1144)
                                       (car binding*1143)
                                       r1142))))]
             [extend-var-env*115 (lambda (label*1141 var*1140 r1139)
                                   (if (null? label*1141)
                                       r1139
                                       (extend-var-env*115
                                         (cdr label*1141)
                                         (cdr var*1140)
                                         (extend-env113
                                           (car label*1141)
                                           (make-binding109
                                             'lexical
                                             (car var*1140))
                                           r1139))))]
             [displaced-lexical-error116 (lambda (id1138)
                                           (syntax-error
                                             id1138
                                             '"identifier out of context"))]
             [eval-transformer117 (lambda (x1136)
                                    ((lambda (x1137)
                                       (if (procedure? x1137)
                                           (make-binding109 'macro x1137)
                                           (if (if (pair? x1137)
                                                   (if (eq? (car x1137)
                                                            'macro!)
                                                       (procedure?
                                                         (cdr x1137))
                                                       '#f)
                                                   '#f)
                                               x1137
                                               (syntax-error
                                                 b
                                                 '"invalid transformer"))))
                                      (eval-hook0 x1136)))]
             [id?118 (lambda (x1135)
                       (if (syntax-object?78 x1135)
                           (symbol?
                             (unannotate87
                               (syntax-object-expression79 x1135)))
                           '#f))]
             [id->sym119 (lambda (x1134)
                           (unannotate87
                             (syntax-object-expression79 x1134)))]
             [gen-var120 (lambda (id1133)
                           (build-lexical-var35
                             (syn->src86 id1133)
                             (id->sym119 id1133)))]
             [id->label121 (lambda (id1124)
                             ((lambda (sym1125)
                                ((letrec ([search1126 (lambda (subst*1128
                                                               mark*1127)
                                                        (if (null?
                                                              subst*1128)
                                                            sym1125
                                                            ((lambda (subst1129)
                                                               (if (eq? subst1129
                                                                        'shift)
                                                                   (search1126
                                                                     (cdr subst*1128)
                                                                     (cdr mark*1127))
                                                                   ((letrec ([search-rib1130 (lambda (sym*1132
                                                                                                      i1131)
                                                                                               (if (null?
                                                                                                     sym*1132)
                                                                                                   (search1126
                                                                                                     (cdr subst*1128)
                                                                                                     mark*1127)
                                                                                                   (if (if (eq? (car sym*1132)
                                                                                                                sym1125)
                                                                                                           (same-marks?94
                                                                                                             mark*1127
                                                                                                             (list-ref
                                                                                                               (rib-mark**100
                                                                                                                 subst1129)
                                                                                                               i1131))
                                                                                                           '#f)
                                                                                                       (list-ref
                                                                                                         (rib-label*101
                                                                                                           subst1129)
                                                                                                         i1131)
                                                                                                       (search-rib1130
                                                                                                         (cdr sym*1132)
                                                                                                         (+ i1131
                                                                                                            '1)))))])
                                                                      search-rib1130)
                                                                     (rib-sym*99
                                                                       subst1129)
                                                                     '0)))
                                                              (car subst*1128))))])
                                   search1126)
                                  (syntax-object-subst*81 id1124)
                                  (syntax-object-mark*80 id1124)))
                               (id->sym119 id1124)))]
             [label->binding122 (lambda (x1122 r1121)
                                  (if (symbol? x1122)
                                      (global-lookup10 x1122)
                                      ((lambda (t1123)
                                         (if t1123
                                             (cdr t1123)
                                             (make-binding109
                                               'displaced-lexical
                                               '#f)))
                                        (assq x1122 r1121))))]
             [free-id=?123 (lambda (i1120 j1119)
                             (eq? (id->label121 i1120)
                                  (id->label121 j1119)))]
             [bound-id=?124 (lambda (i1118 j1117)
                              (if (eq? (id->sym119 i1118)
                                       (id->sym119 j1117))
                                  (same-marks?94
                                    (syntax-object-mark*80 i1118)
                                    (syntax-object-mark*80 j1117))
                                  '#f))]
             [bound-id-member?125 (lambda (x1115 list1114)
                                    (if (not (null? list1114))
                                        ((lambda (t1116)
                                           (if t1116
                                               t1116
                                               (bound-id-member?125
                                                 x1115
                                                 (cdr list1114))))
                                          (bound-id=?124
                                            x1115
                                            (car list1114)))
                                        '#f))]
             [valid-bound-ids?126 (lambda (id*1110)
                                    (if ((letrec ([all-ids?1111 (lambda (id*1112)
                                                                  ((lambda (t1113)
                                                                     (if t1113
                                                                         t1113
                                                                         (if (id?118
                                                                               (car id*1112))
                                                                             (all-ids?1111
                                                                               (cdr id*1112))
                                                                             '#f)))
                                                                    (null?
                                                                      id*1112)))])
                                           all-ids?1111)
                                          id*1110)
                                        (distinct-bound-ids?127 id*1110)
                                        '#f))]
             [distinct-bound-ids?127 (lambda (id*1106)
                                       ((letrec ([distinct?1107 (lambda (id*1108)
                                                                  ((lambda (t1109)
                                                                     (if t1109
                                                                         t1109
                                                                         (if (not (bound-id-member?125
                                                                                    (car id*1108)
                                                                                    (cdr id*1108)))
                                                                             (distinct?1107
                                                                               (cdr id*1108))
                                                                             '#f)))
                                                                    (null?
                                                                      id*1108)))])
                                          distinct?1107)
                                         id*1106))]
             [invalid-ids-error128 (lambda (id*1102 e1101 class1100)
                                     ((letrec ([find1103 (lambda (id*1105
                                                                  ok*1104)
                                                           (if (null?
                                                                 id*1105)
                                                               (syntax-error
                                                                 e1101)
                                                               (if (id?118
                                                                     (car id*1105))
                                                                   (if (bound-id-member?125
                                                                         (car id*1105)
                                                                         ok*1104)
                                                                       (syntax-error
                                                                         (car id*1105)
                                                                         '"duplicate "
                                                                         class1100)
                                                                       (find1103
                                                                         (cdr id*1105)
                                                                         (cons
                                                                           (car id*1105)
                                                                           ok*1104)))
                                                                   (syntax-error
                                                                     (car id*1105)
                                                                     '"invalid "
                                                                     class1100))))])
                                        find1103)
                                       id*1102
                                       '()))])
     (begin
       ((lambda ()
          (letrec* ([syntax-type612 (lambda (e1083 r1082)
                                      ((lambda (tmp1084)
                                         ((lambda (tmp1085)
                                            (if (if tmp1085
                                                    (apply
                                                      (lambda (id1086)
                                                        (id?118 id1086))
                                                      tmp1085)
                                                    '#f)
                                                (apply
                                                  (lambda (id1087)
                                                    ((lambda (label1088)
                                                       ((lambda (b1089)
                                                          ((lambda (type1090)
                                                             ((lambda (t1091)
                                                                (if (memv
                                                                      t1091
                                                                      '(macro
                                                                         macro!
                                                                         lexical
                                                                         global
                                                                         syntax
                                                                         displaced-lexical))
                                                                    (values
                                                                      type1090
                                                                      (binding-value111
                                                                        b1089))
                                                                    (values
                                                                      'other
                                                                      '#f)))
                                                               type1090))
                                                            (binding-type110
                                                              b1089)))
                                                         (label->binding122
                                                           label1088
                                                           r1082)))
                                                      (id->label121
                                                        id1087)))
                                                  tmp1085)
                                                ((lambda (tmp1092)
                                                   (if tmp1092
                                                       (apply
                                                         (lambda (id1094
                                                                  rest1093)
                                                           (if (id?118
                                                                 id1094)
                                                               ((lambda (label1095)
                                                                  ((lambda (b1096)
                                                                     ((lambda (type1097)
                                                                        ((lambda (t1098)
                                                                           (if (memv
                                                                                 t1098
                                                                                 '(macro
                                                                                    macro!
                                                                                    core
                                                                                    begin
                                                                                    define
                                                                                    define-syntax
                                                                                    local-syntax))
                                                                               (values
                                                                                 type1097
                                                                                 (binding-value111
                                                                                   b1096))
                                                                               (values
                                                                                 'call
                                                                                 '#f)))
                                                                          type1097))
                                                                       (binding-type110
                                                                         b1096)))
                                                                    (label->binding122
                                                                      label1095
                                                                      r1082)))
                                                                 (id->label121
                                                                   id1094))
                                                               (values
                                                                 'call
                                                                 '#f)))
                                                         tmp1092)
                                                       ((lambda (d1099)
                                                          (if (self-evaluating?36
                                                                d1099)
                                                              (values
                                                                'constant
                                                                d1099)
                                                              (values
                                                                'other
                                                                '#f)))
                                                         (strip85
                                                           e1083
                                                           '()))))
                                                  ($syntax-dispatch
                                                    tmp1084
                                                    '(any . any)))))
                                           ($syntax-dispatch
                                             tmp1084
                                             'any)))
                                        e1083))]
                    [chi613 (lambda (e1075 r1074 mr1073)
                              (call-with-values
                                (lambda () (syntax-type612 e1075 r1074))
                                (lambda (type1077 value1076)
                                  ((lambda (t1078)
                                     (if (memv t1078 '(lexical))
                                         (build-lexical-reference26
                                           (syn->src86 e1075)
                                           value1076)
                                         (if (memv t1078 '(global))
                                             (build-global-reference25
                                               (syn->src86 e1075)
                                               value1076)
                                             (if (memv t1078 '(core))
                                                 (value1076
                                                   e1075
                                                   r1074
                                                   mr1073)
                                                 (if (memv
                                                       t1078
                                                       '(constant))
                                                     (build-data31
                                                       (syn->src86 e1075)
                                                       value1076)
                                                     (if (memv
                                                           t1078
                                                           '(call))
                                                         (chi-application615
                                                           e1075
                                                           r1074
                                                           mr1073)
                                                         (if (memv
                                                               t1078
                                                               '(begin))
                                                             (build-sequence32
                                                               (syn->src86
                                                                 e1075)
                                                               (chi-exprs614
                                                                 (parse-begin620
                                                                   e1075
                                                                   '#f)
                                                                 r1074
                                                                 mr1073))
                                                             (if (memv
                                                                   t1078
                                                                   '(macro
                                                                      macro!))
                                                                 (chi613
                                                                   (chi-macro616
                                                                     value1076
                                                                     e1075)
                                                                   r1074
                                                                   mr1073)
                                                                 (if (memv
                                                                       t1078
                                                                       '(local-syntax))
                                                                     (call-with-values
                                                                       (lambda ()
                                                                         (chi-local-syntax621
                                                                           value1076
                                                                           e1075
                                                                           r1074
                                                                           mr1073))
                                                                       (lambda (e*1081
                                                                                r1080
                                                                                mr1079)
                                                                         (build-sequence32
                                                                           (syn->src86
                                                                             e1075)
                                                                           (chi-exprs614
                                                                             e*1081
                                                                             r1080
                                                                             mr1079))))
                                                                     (if (memv
                                                                           t1078
                                                                           '(define))
                                                                         (begin
                                                                           (parse-define618
                                                                             e1075)
                                                                           (syntax-error
                                                                             e1075
                                                                             '"invalid context for definition"))
                                                                         (if (memv
                                                                               t1078
                                                                               '(define-syntax))
                                                                             (begin
                                                                               (parse-define-syntax619
                                                                                 e1075)
                                                                               (syntax-error
                                                                                 e1075
                                                                                 '"invalid context for definition"))
                                                                             (if (memv
                                                                                   t1078
                                                                                   '(syntax))
                                                                                 (syntax-error
                                                                                   e1075
                                                                                   '"reference to pattern variable outside syntax form")
                                                                                 (if (memv
                                                                                       t1078
                                                                                       '(displaced-lexical))
                                                                                     (displaced-lexical-error116
                                                                                       e1075)
                                                                                     (syntax-error
                                                                                       e1075))))))))))))))
                                    type1077))))]
                    [chi-exprs614 (lambda (x*1071 r1070 mr1069)
                                    (map (lambda (x1072)
                                           (chi613 x1072 r1070 mr1069))
                                         x*1071))]
                    [chi-application615 (lambda (e1063 r1062 mr1061)
                                          ((lambda (tmp1064)
                                             ((lambda (tmp1065)
                                                (if tmp1065
                                                    (apply
                                                      (lambda (e01067
                                                               e11066)
                                                        (build-application11
                                                          (syn->src86
                                                            e1063)
                                                          (chi613
                                                            e01067
                                                            r1062
                                                            mr1061)
                                                          (chi-exprs614
                                                            e11066
                                                            r1062
                                                            mr1061)))
                                                      tmp1065)
                                                    (syntax-error
                                                      tmp1064)))
                                               ($syntax-dispatch
                                                 tmp1064
                                                 '(any . each-any))))
                                            e1063))]
                    [chi-macro616 (lambda (p1058 orig-e1057)
                                    ((lambda (e1059)
                                       ((lambda (e1060)
                                          (add-mark93 (gen-mark90) e1060))
                                         (if (syntax-object?78 e1059)
                                             e1059
                                             (make-syntax-object77
                                               e1059
                                               '()
                                               '()))))
                                      (p1058 (anti-mark92 orig-e1057))))]
                    [chi-body617 (lambda (outer-e1032 e*1031 r1030 mr1029)
                                   ((lambda (rib1033)
                                      ((letrec ([parse1035 (lambda (e*1041
                                                                    r1040
                                                                    mr1039
                                                                    id*1038
                                                                    var*1037
                                                                    rhs*1036)
                                                             (if (null?
                                                                   e*1041)
                                                                 (syntax-error
                                                                   outer-e1032
                                                                   '"no expressions in body")
                                                                 ((lambda (e1042)
                                                                    (call-with-values
                                                                      (lambda ()
                                                                        (syntax-type612
                                                                          e1042
                                                                          r1040))
                                                                      (lambda (type1044
                                                                               value1043)
                                                                        ((lambda (t1045)
                                                                           (if (memv
                                                                                 t1045
                                                                                 '(define))
                                                                               (call-with-values
                                                                                 (lambda ()
                                                                                   (parse-define618
                                                                                     e1042))
                                                                                 (lambda (id1047
                                                                                          rhs1046)
                                                                                   ((lambda (label1049
                                                                                             var1048)
                                                                                      (begin
                                                                                        (extend-rib!106
                                                                                          rib1033
                                                                                          id1047
                                                                                          label1049)
                                                                                        (parse1035
                                                                                          (cdr e*1041)
                                                                                          (extend-env113
                                                                                            label1049
                                                                                            (make-binding109
                                                                                              'lexical
                                                                                              var1048)
                                                                                            r1040)
                                                                                          mr1039
                                                                                          (cons
                                                                                            id1047
                                                                                            id*1038)
                                                                                          (cons
                                                                                            var1048
                                                                                            var*1037)
                                                                                          (cons
                                                                                            rhs1046
                                                                                            rhs*1036))))
                                                                                     (gen-label108)
                                                                                     (gen-var120
                                                                                       id1047))))
                                                                               (if (memv
                                                                                     t1045
                                                                                     '(define-syntax))
                                                                                   (call-with-values
                                                                                     (lambda ()
                                                                                       (parse-define-syntax619
                                                                                         e1042))
                                                                                     (lambda (id1051
                                                                                              rhs1050)
                                                                                       ((lambda (label1052)
                                                                                          (begin
                                                                                            (extend-rib!106
                                                                                              rib1033
                                                                                              id1051
                                                                                              label1052)
                                                                                            ((lambda (b1053)
                                                                                               (parse1035
                                                                                                 (cdr e*1041)
                                                                                                 (extend-env113
                                                                                                   label1052
                                                                                                   b1053
                                                                                                   r1040)
                                                                                                 (extend-env113
                                                                                                   label1052
                                                                                                   b1053
                                                                                                   mr1039)
                                                                                                 (cons
                                                                                                   id1051
                                                                                                   id*1038)
                                                                                                 var*1037
                                                                                                 rhs*1036))
                                                                                              (eval-transformer117
                                                                                                (chi613
                                                                                                  rhs1050
                                                                                                  mr1039
                                                                                                  mr1039)))))
                                                                                         (gen-label108))))
                                                                                   (if (memv
                                                                                         t1045
                                                                                         '(begin))
                                                                                       (parse1035
                                                                                         (append
                                                                                           (parse-begin620
                                                                                             e1042
                                                                                             '#t)
                                                                                           (cdr e*1041))
                                                                                         r1040
                                                                                         mr1039
                                                                                         id*1038
                                                                                         var*1037
                                                                                         rhs*1036)
                                                                                       (if (memv
                                                                                             t1045
                                                                                             '(macro
                                                                                                macro!))
                                                                                           (parse1035
                                                                                             (cons
                                                                                               (add-subst96
                                                                                                 rib1033
                                                                                                 (chi-macro616
                                                                                                   value1043
                                                                                                   e1042))
                                                                                               (cdr e*1041))
                                                                                             r1040
                                                                                             mr1039
                                                                                             id*1038
                                                                                             var*1037
                                                                                             rhs*1036)
                                                                                           (if (memv
                                                                                                 t1045
                                                                                                 '(local-syntax))
                                                                                               (call-with-values
                                                                                                 (lambda ()
                                                                                                   (chi-local-syntax621
                                                                                                     value1043
                                                                                                     e1042
                                                                                                     r1040
                                                                                                     mr1039))
                                                                                                 (lambda (new-e*1056
                                                                                                          r1055
                                                                                                          mr1054)
                                                                                                   (parse1035
                                                                                                     (append
                                                                                                       new-e*1056
                                                                                                       (cdr e*1041))
                                                                                                     r1055
                                                                                                     mr1054
                                                                                                     id*1038
                                                                                                     var*1037
                                                                                                     rhs*1036)))
                                                                                               (begin
                                                                                                 (if (not (valid-bound-ids?126
                                                                                                            id*1038))
                                                                                                     (invalid-ids-error128
                                                                                                       id*1038
                                                                                                       outer-e1032
                                                                                                       '"locally defined identifier")
                                                                                                     (void))
                                                                                                 (build-letrec*34
                                                                                                   no-source3
                                                                                                   (reverse
                                                                                                     var*1037)
                                                                                                   (chi-exprs614
                                                                                                     (reverse
                                                                                                       rhs*1036)
                                                                                                     r1040
                                                                                                     mr1039)
                                                                                                   (build-sequence32
                                                                                                     no-source3
                                                                                                     (chi-exprs614
                                                                                                       (cons
                                                                                                         e1042
                                                                                                         (cdr e*1041))
                                                                                                       r1040
                                                                                                       mr1039))))))))))
                                                                          type1044))))
                                                                   (car e*1041))))])
                                         parse1035)
                                        (map (lambda (e1034)
                                               (add-subst96 rib1033 e1034))
                                             e*1031)
                                        r1030 mr1029 '() '() '()))
                                     (make-empty-rib105)))]
                    [parse-define618 (lambda (e998)
                                       (letrec* ([valid-args?999 (lambda (args1019)
                                                                   (valid-bound-ids?126
                                                                     ((lambda (tmp1020)
                                                                        ((lambda (tmp1021)
                                                                           (if tmp1021
                                                                               (apply
                                                                                 (lambda (id1022)
                                                                                   id1022)
                                                                                 tmp1021)
                                                                               ((lambda (tmp1024)
                                                                                  (if tmp1024
                                                                                      (apply
                                                                                        (lambda (id1026
                                                                                                 r1025)
                                                                                          (append
                                                                                            id1026
                                                                                            (cons
                                                                                              r1025
                                                                                              '#(syntax-object
                                                                                                 ()
                                                                                                 (top)
                                                                                                 ()))))
                                                                                        tmp1024)
                                                                                      ((lambda (id1028)
                                                                                         (cons
                                                                                           id1028
                                                                                           '#(syntax-object
                                                                                              ()
                                                                                              (top)
                                                                                              ())))
                                                                                        tmp1020)))
                                                                                 ($syntax-dispatch
                                                                                   tmp1020
                                                                                   '#(each+
                                                                                      any
                                                                                      ()
                                                                                      any)))))
                                                                          ($syntax-dispatch
                                                                            tmp1020
                                                                            'each-any)))
                                                                       args1019)))])
                                         ((lambda (tmp1000)
                                            ((lambda (tmp1001)
                                               (if (if tmp1001
                                                       (apply
                                                         (lambda (name1003
                                                                  e1002)
                                                           (id?118
                                                             name1003))
                                                         tmp1001)
                                                       '#f)
                                                   (apply
                                                     (lambda (name1005
                                                              e1004)
                                                       (values
                                                         name1005
                                                         e1004))
                                                     tmp1001)
                                                   ((lambda (tmp1006)
                                                      (if (if tmp1006
                                                              (apply
                                                                (lambda (name1010
                                                                         args1009
                                                                         e11008
                                                                         e21007)
                                                                  (if (id?118
                                                                        name1010)
                                                                      (valid-args?999
                                                                        args1009)
                                                                      '#f))
                                                                tmp1006)
                                                              '#f)
                                                          (apply
                                                            (lambda (name1014
                                                                     args1013
                                                                     e11012
                                                                     e21011)
                                                              (values
                                                                name1014
                                                                (cons
                                                                  '#(syntax-object
                                                                     lambda
                                                                     (top)
                                                                     ())
                                                                  (cons
                                                                    args1013
                                                                    (cons
                                                                      e11012
                                                                      e21011)))))
                                                            tmp1006)
                                                          ((lambda (tmp1016)
                                                             (if (if tmp1016
                                                                     (apply
                                                                       (lambda (name1017)
                                                                         (id?118
                                                                           name1017))
                                                                       tmp1016)
                                                                     '#f)
                                                                 (apply
                                                                   (lambda (name1018)
                                                                     (values
                                                                       name1018
                                                                       '#(syntax-object
                                                                          (void)
                                                                          (top)
                                                                          ())))
                                                                   tmp1016)
                                                                 (syntax-error
                                                                   tmp1000)))
                                                            ($syntax-dispatch
                                                              tmp1000
                                                              '(_ any)))))
                                                     ($syntax-dispatch
                                                       tmp1000
                                                       '(_ (any . any)
                                                           any
                                                           .
                                                           each-any)))))
                                              ($syntax-dispatch
                                                tmp1000
                                                '(_ any any))))
                                           e998)))]
                    [parse-define-syntax619 (lambda (e991)
                                              ((lambda (tmp992)
                                                 ((lambda (tmp993)
                                                    (if (if tmp993
                                                            (apply
                                                              (lambda (name995
                                                                       rhs994)
                                                                (id?118
                                                                  name995))
                                                              tmp993)
                                                            '#f)
                                                        (apply
                                                          (lambda (name997
                                                                   rhs996)
                                                            (values
                                                              name997
                                                              rhs996))
                                                          tmp993)
                                                        (syntax-error
                                                          tmp992)))
                                                   ($syntax-dispatch
                                                     tmp992
                                                     '(_ any any))))
                                                e991))]
                    [parse-begin620 (lambda (e984 empty-okay?983)
                                      ((lambda (tmp985)
                                         ((lambda (tmp986)
                                            (if (if tmp986
                                                    (apply
                                                      (lambda ()
                                                        empty-okay?983)
                                                      tmp986)
                                                    '#f)
                                                (apply
                                                  (lambda () '())
                                                  tmp986)
                                                ((lambda (tmp987)
                                                   (if tmp987
                                                       (apply
                                                         (lambda (e1989
                                                                  e2988)
                                                           (cons
                                                             e1989
                                                             e2988))
                                                         tmp987)
                                                       (syntax-error
                                                         tmp985)))
                                                  ($syntax-dispatch
                                                    tmp985
                                                    '(_ any . each-any)))))
                                           ($syntax-dispatch tmp985 '(_))))
                                        e984))]
                    [chi-local-syntax621 (lambda (rec?964 e963 r962 mr961)
                                           ((lambda (tmp965)
                                              ((lambda (tmp966)
                                                 (if tmp966
                                                     (apply
                                                       (lambda (id970
                                                                rhs969
                                                                e1968
                                                                e2967)
                                                         ((lambda (id*974
                                                                   rhs*973)
                                                            (begin
                                                              (if (not (valid-bound-ids?126
                                                                         id*974))
                                                                  (invalid-ids-error128
                                                                    id*974
                                                                    e963
                                                                    '"keyword")
                                                                  (void))
                                                              ((lambda (label*976)
                                                                 ((lambda (rib977)
                                                                    ((lambda (b*980)
                                                                       (values
                                                                         (map (lambda (e982)
                                                                                (add-subst96
                                                                                  rib977
                                                                                  e982))
                                                                              (cons
                                                                                e1968
                                                                                e2967))
                                                                         (extend-env*114
                                                                           label*976
                                                                           b*980
                                                                           r962)
                                                                         (extend-env*114
                                                                           label*976
                                                                           b*980
                                                                           mr961)))
                                                                      (map (lambda (x979)
                                                                             (eval-transformer117
                                                                               (chi613
                                                                                 x979
                                                                                 mr961
                                                                                 mr961)))
                                                                           (if rec?964
                                                                               (map (lambda (x978)
                                                                                      (add-subst96
                                                                                        rib977
                                                                                        x978))
                                                                                    rhs*973)
                                                                               rhs*973))))
                                                                   (make-full-rib107
                                                                     id*974
                                                                     label*976)))
                                                                (map (lambda (x975)
                                                                       (gen-label108))
                                                                     id*974))))
                                                           id970
                                                           rhs969))
                                                       tmp966)
                                                     (syntax-error
                                                       tmp965)))
                                                ($syntax-dispatch
                                                  tmp965
                                                  '(_ #(each (any any))
                                                      any
                                                      .
                                                      each-any))))
                                             e963))]
                    [ellipsis?622 (lambda (x960)
                                    (if (id?118 x960)
                                        (free-id=?123
                                          x960
                                          '#(syntax-object ... (top) ()))
                                        '#f))])
            (begin
              (set! sc-expand
                (lambda (x959)
                  (chi613
                    (make-syntax-object77 x959 top-mark*88 top-subst*95)
                    null-env112
                    null-env112)))
              (global-extend9 'begin 'begin '#f)
              (global-extend9 'define 'define '#f)
              (global-extend9 'define-syntax 'define-syntax '#f)
              (global-extend9 'local-syntax 'letrec-syntax '#t)
              (global-extend9 'local-syntax 'let-syntax '#f)
              (global-extend9
                'core
                'quote
                (lambda (e955 r954 mr953)
                  ((lambda (tmp956)
                     ((lambda (tmp957)
                        (if tmp957
                            (apply
                              (lambda (e958)
                                (build-data31
                                  (syn->src86 e958)
                                  (strip85 e958 '())))
                              tmp957)
                            (syntax-error tmp956)))
                       ($syntax-dispatch tmp956 '(_ any))))
                    e955)))
              (global-extend9
                'core
                'lambda
                (lambda (e924 r923 mr922)
                  (letrec* ([help925 (lambda (var*947 rest?946 e*945)
                                       (begin
                                         (if (not (valid-bound-ids?126
                                                    var*947))
                                             (invalid-ids-error128
                                               var*947
                                               e924
                                               '"parameter")
                                             (void))
                                         ((lambda (label*950 new-var*949)
                                            (build-lambda29
                                              (syn->src86 e924)
                                              new-var*949
                                              rest?946
                                              (chi-body617
                                                e924
                                                ((lambda (rib951)
                                                   (map (lambda (e952)
                                                          (add-subst96
                                                            rib951
                                                            e952))
                                                        e*945))
                                                  (make-full-rib107
                                                    var*947
                                                    label*950))
                                                (extend-var-env*115
                                                  label*950
                                                  new-var*949
                                                  r923)
                                                mr922)))
                                           (map (lambda (x948)
                                                  (gen-label108))
                                                var*947)
                                           (map gen-var120 var*947))))])
                    ((lambda (tmp926)
                       ((lambda (tmp927)
                          (if tmp927
                              (apply
                                (lambda (var930 e1929 e2928)
                                  (help925 var930 '#f (cons e1929 e2928)))
                                tmp927)
                              ((lambda (tmp933)
                                 (if tmp933
                                     (apply
                                       (lambda (var937 rvar936 e1935 e2934)
                                         (help925
                                           (append
                                             var937
                                             (cons rvar936 '()))
                                           '#t
                                           (cons e1935 e2934)))
                                       tmp933)
                                     ((lambda (tmp940)
                                        (if tmp940
                                            (apply
                                              (lambda (var943 e1942 e2941)
                                                (help925
                                                  (cons var943 '())
                                                  '#t
                                                  (cons e1942 e2941)))
                                              tmp940)
                                            (syntax-error tmp926)))
                                       ($syntax-dispatch
                                         tmp926
                                         '(_ any any . each-any)))))
                                ($syntax-dispatch
                                  tmp926
                                  '(_ #(each+ any () any)
                                      any
                                      .
                                      each-any)))))
                         ($syntax-dispatch
                           tmp926
                           '(_ each-any any . each-any))))
                      e924))))
              (global-extend9
                'core
                'letrec
                (lambda (e902 r901 mr900)
                  ((lambda (tmp903)
                     ((lambda (tmp904)
                        (if tmp904
                            (apply
                              (lambda (var908 rhs907 e1906 e2905)
                                ((lambda (var*914 rhs*913 e*912)
                                   (begin
                                     (if (not (valid-bound-ids?126
                                                var*914))
                                         (invalid-ids-error128
                                           var*914
                                           e902
                                           '"bound variable")
                                         (void))
                                     ((lambda (label*917 new-var*916)
                                        ((lambda (r919 rib918)
                                           (build-letrec33
                                             (syn->src86 e902)
                                             new-var*916
                                             (map (lambda (e921)
                                                    (chi613
                                                      (add-subst96
                                                        rib918
                                                        e921)
                                                      r919
                                                      mr900))
                                                  rhs*913)
                                             (chi-body617
                                               e902
                                               (map (lambda (e920)
                                                      (add-subst96
                                                        rib918
                                                        e920))
                                                    e*912)
                                               r919
                                               mr900)))
                                          (extend-var-env*115
                                            label*917
                                            new-var*916
                                            r901)
                                          (make-full-rib107
                                            var*914
                                            label*917)))
                                       (map (lambda (x915) (gen-label108))
                                            var*914)
                                       (map gen-var120 var*914))))
                                  var908
                                  rhs907
                                  (cons e1906 e2905)))
                              tmp904)
                            (syntax-error tmp903)))
                       ($syntax-dispatch
                         tmp903
                         '(_ #(each (any any)) any . each-any))))
                    e902)))
              (global-extend9
                'core
                'letrec*
                (lambda (e880 r879 mr878)
                  ((lambda (tmp881)
                     ((lambda (tmp882)
                        (if tmp882
                            (apply
                              (lambda (var886 rhs885 e1884 e2883)
                                ((lambda (var*892 rhs*891 e*890)
                                   (begin
                                     (if (not (valid-bound-ids?126
                                                var*892))
                                         (invalid-ids-error128
                                           var*892
                                           e880
                                           '"bound variable")
                                         (void))
                                     ((lambda (label*895 new-var*894)
                                        ((lambda (r897 rib896)
                                           (build-letrec*34
                                             (syn->src86 e880)
                                             new-var*894
                                             (map (lambda (e899)
                                                    (chi613
                                                      (add-subst96
                                                        rib896
                                                        e899)
                                                      r897
                                                      mr878))
                                                  rhs*891)
                                             (chi-body617
                                               e880
                                               (map (lambda (e898)
                                                      (add-subst96
                                                        rib896
                                                        e898))
                                                    e*890)
                                               r897
                                               mr878)))
                                          (extend-var-env*115
                                            label*895
                                            new-var*894
                                            r879)
                                          (make-full-rib107
                                            var*892
                                            label*895)))
                                       (map (lambda (x893) (gen-label108))
                                            var*892)
                                       (map gen-var120 var*892))))
                                  var886
                                  rhs885
                                  (cons e1884 e2883)))
                              tmp882)
                            (syntax-error tmp881)))
                       ($syntax-dispatch
                         tmp881
                         '(_ #(each (any any)) any . each-any))))
                    e880)))
              (global-extend9
                'core
                'set!
                (lambda (e869 r868 mr867)
                  ((lambda (tmp870)
                     ((lambda (tmp871)
                        (if (if tmp871
                                (apply
                                  (lambda (id873 rhs872) (id?118 id873))
                                  tmp871)
                                '#f)
                            (apply
                              (lambda (id875 rhs874)
                                ((lambda (b876)
                                   ((lambda (t877)
                                      (if (memv t877 '(macro!))
                                          (chi613
                                            (chi-macro616
                                              (binding-value111 b876)
                                              e869)
                                            r868
                                            mr867)
                                          (if (memv t877 '(lexical))
                                              (build-lexical-assignment27
                                                (syn->src86 e869)
                                                (binding-value111 b876)
                                                (chi613 rhs874 r868 mr867))
                                              (if (memv t877 '(global))
                                                  (build-global-assignment28
                                                    (syn->src86 e869)
                                                    (binding-value111 b876)
                                                    (chi613
                                                      rhs874
                                                      r868
                                                      mr867))
                                                  (if (memv
                                                        t877
                                                        '(displaced-lexical))
                                                      (displaced-lexical-error116
                                                        id875)
                                                      (syntax-error
                                                        e869))))))
                                     (binding-type110 b876)))
                                  (label->binding122
                                    (id->label121 id875)
                                    r868)))
                              tmp871)
                            (syntax-error tmp870)))
                       ($syntax-dispatch tmp870 '(_ any any))))
                    e869)))
              (global-extend9
                'core
                'if
                (lambda (e858 r857 mr856)
                  ((lambda (tmp859)
                     ((lambda (tmp860)
                        (if tmp860
                            (apply
                              (lambda (test862 then861)
                                (cons
                                  'if
                                  (cons
                                    (chi613 test862 r857 mr856)
                                    (cons
                                      (chi613 then861 r857 mr856)
                                      '((void))))))
                              tmp860)
                            ((lambda (tmp863)
                               (if tmp863
                                   (apply
                                     (lambda (test866 then865 else864)
                                       (cons
                                         'if
                                         (cons
                                           (chi613 test866 r857 mr856)
                                           (cons
                                             (chi613 then865 r857 mr856)
                                             (cons
                                               (chi613 else864 r857 mr856)
                                               '())))))
                                     tmp863)
                                   (syntax-error tmp859)))
                              ($syntax-dispatch tmp859 '(_ any any any)))))
                       ($syntax-dispatch tmp859 '(_ any any))))
                    e858)))
              (global-extend9
                'core
                'syntax-case
                ((lambda ()
                   (letrec* ([convert-pattern746 (lambda (pattern805
                                                          keys804)
                                                   (letrec* ([cvt*806 (lambda (p*851
                                                                               n850
                                                                               ids849)
                                                                        (if (null?
                                                                              p*851)
                                                                            (values
                                                                              '()
                                                                              ids849)
                                                                            (call-with-values
                                                                              (lambda ()
                                                                                (cvt*806
                                                                                  (cdr p*851)
                                                                                  n850
                                                                                  ids849))
                                                                              (lambda (y853
                                                                                       ids852)
                                                                                (call-with-values
                                                                                  (lambda ()
                                                                                    (cvt807
                                                                                      (car p*851)
                                                                                      n850
                                                                                      ids852))
                                                                                  (lambda (x855
                                                                                           ids854)
                                                                                    (values
                                                                                      (cons
                                                                                        x855
                                                                                        y853)
                                                                                      ids854)))))))]
                                                             [cvt807 (lambda (p810
                                                                              n809
                                                                              ids808)
                                                                       (if (not (id?118
                                                                                  p810))
                                                                           ((lambda (tmp811)
                                                                              ((lambda (tmp812)
                                                                                 (if (if tmp812
                                                                                         (apply
                                                                                           (lambda (x814
                                                                                                    dots813)
                                                                                             (ellipsis?622
                                                                                               dots813))
                                                                                           tmp812)
                                                                                         '#f)
                                                                                     (apply
                                                                                       (lambda (x816
                                                                                                dots815)
                                                                                         (call-with-values
                                                                                           (lambda ()
                                                                                             (cvt807
                                                                                               x816
                                                                                               (+ n809
                                                                                                  '1)
                                                                                               ids808))
                                                                                           (lambda (p818
                                                                                                    ids817)
                                                                                             (values
                                                                                               (if (eq? p818
                                                                                                        'any)
                                                                                                   'each-any
                                                                                                   (vector
                                                                                                     'each
                                                                                                     p818))
                                                                                               ids817))))
                                                                                       tmp812)
                                                                                     ((lambda (tmp819)
                                                                                        (if (if tmp819
                                                                                                (apply
                                                                                                  (lambda (x823
                                                                                                           dots822
                                                                                                           y821
                                                                                                           z820)
                                                                                                    (ellipsis?622
                                                                                                      dots822))
                                                                                                  tmp819)
                                                                                                '#f)
                                                                                            (apply
                                                                                              (lambda (x827
                                                                                                       dots826
                                                                                                       y825
                                                                                                       z824)
                                                                                                (call-with-values
                                                                                                  (lambda ()
                                                                                                    (cvt807
                                                                                                      z824
                                                                                                      n809
                                                                                                      ids808))
                                                                                                  (lambda (z829
                                                                                                           ids828)
                                                                                                    (call-with-values
                                                                                                      (lambda ()
                                                                                                        (cvt*806
                                                                                                          y825
                                                                                                          n809
                                                                                                          ids828))
                                                                                                      (lambda (y831
                                                                                                               ids830)
                                                                                                        (call-with-values
                                                                                                          (lambda ()
                                                                                                            (cvt807
                                                                                                              x827
                                                                                                              (+ n809
                                                                                                                 '1)
                                                                                                              ids830))
                                                                                                          (lambda (x833
                                                                                                                   ids832)
                                                                                                            (values
                                                                                                              (list->vector
                                                                                                                (cons
                                                                                                                  'each+
                                                                                                                  (cons
                                                                                                                    x833
                                                                                                                    (cons
                                                                                                                      (reverse
                                                                                                                        y831)
                                                                                                                      (list
                                                                                                                        z829)))))
                                                                                                              ids832))))))))
                                                                                              tmp819)
                                                                                            ((lambda (tmp835)
                                                                                               (if tmp835
                                                                                                   (apply
                                                                                                     (lambda (x837
                                                                                                              y836)
                                                                                                       (call-with-values
                                                                                                         (lambda ()
                                                                                                           (cvt807
                                                                                                             y836
                                                                                                             n809
                                                                                                             ids808))
                                                                                                         (lambda (y839
                                                                                                                  ids838)
                                                                                                           (call-with-values
                                                                                                             (lambda ()
                                                                                                               (cvt807
                                                                                                                 x837
                                                                                                                 n809
                                                                                                                 ids838))
                                                                                                             (lambda (x841
                                                                                                                      ids840)
                                                                                                               (values
                                                                                                                 (cons
                                                                                                                   x841
                                                                                                                   y839)
                                                                                                                 ids840))))))
                                                                                                     tmp835)
                                                                                                   ((lambda (tmp842)
                                                                                                      (if tmp842
                                                                                                          (apply
                                                                                                            (lambda ()
                                                                                                              (values
                                                                                                                '()
                                                                                                                ids808))
                                                                                                            tmp842)
                                                                                                          ((lambda (tmp843)
                                                                                                             (if tmp843
                                                                                                                 (apply
                                                                                                                   (lambda (x844)
                                                                                                                     (call-with-values
                                                                                                                       (lambda ()
                                                                                                                         (cvt807
                                                                                                                           x844
                                                                                                                           n809
                                                                                                                           ids808))
                                                                                                                       (lambda (p846
                                                                                                                                ids845)
                                                                                                                         (values
                                                                                                                           (vector
                                                                                                                             'vector
                                                                                                                             p846)
                                                                                                                           ids845))))
                                                                                                                   tmp843)
                                                                                                                 ((lambda (x848)
                                                                                                                    (values
                                                                                                                      (vector
                                                                                                                        'atom
                                                                                                                        (strip85
                                                                                                                          p810
                                                                                                                          '()))
                                                                                                                      ids808))
                                                                                                                   tmp811)))
                                                                                                            ($syntax-dispatch
                                                                                                              tmp811
                                                                                                              '#(vector
                                                                                                                 each-any)))))
                                                                                                     ($syntax-dispatch
                                                                                                       tmp811
                                                                                                       '()))))
                                                                                              ($syntax-dispatch
                                                                                                tmp811
                                                                                                '(any .
                                                                                                      any)))))
                                                                                       ($syntax-dispatch
                                                                                         tmp811
                                                                                         '(any any
                                                                                               .
                                                                                               #(each+
                                                                                                 any
                                                                                                 ()
                                                                                                 any))))))
                                                                                ($syntax-dispatch
                                                                                  tmp811
                                                                                  '(any any))))
                                                                             p810)
                                                                           (if (bound-id-member?125
                                                                                 p810
                                                                                 keys804)
                                                                               (values
                                                                                 (vector
                                                                                   'free-id
                                                                                   p810)
                                                                                 ids808)
                                                                               (if (free-id=?123
                                                                                     p810
                                                                                     '#(syntax-object
                                                                                        _
                                                                                        (top)
                                                                                        ()))
                                                                                   (values
                                                                                     '_
                                                                                     ids808)
                                                                                   (values
                                                                                     'any
                                                                                     (cons
                                                                                       (cons
                                                                                         p810
                                                                                         n809)
                                                                                       ids808))))))])
                                                     (cvt807
                                                       pattern805
                                                       '0
                                                       '())))]
                             [build-dispatch-call747 (lambda (pvars796
                                                              expr795 y794
                                                              r793 mr792)
                                                       ((lambda (ids798
                                                                 levels797)
                                                          ((lambda (labels801
                                                                    new-vars800)
                                                             (build-application11
                                                               no-source3
                                                               (build-primref30
                                                                 no-source3
                                                                 'apply)
                                                               (list
                                                                 (build-lambda29
                                                                   no-source3
                                                                   new-vars800
                                                                   '#f
                                                                   (chi613
                                                                     (add-subst96
                                                                       (make-full-rib107
                                                                         ids798
                                                                         labels801)
                                                                       expr795)
                                                                     (extend-env*114
                                                                       labels801
                                                                       (map (lambda (var803
                                                                                     level802)
                                                                              (make-binding109
                                                                                'syntax
                                                                                (cons
                                                                                  var803
                                                                                  level802)))
                                                                            new-vars800
                                                                            (map cdr
                                                                                 pvars796))
                                                                       r793)
                                                                     mr792))
                                                                 y794)))
                                                            (map (lambda (x799)
                                                                   (gen-label108))
                                                                 ids798)
                                                            (map gen-var120
                                                                 ids798)))
                                                         (map car pvars796)
                                                         (map cdr
                                                              pvars796)))]
                             [gen-clause748 (lambda (x785 keys784
                                                     clauses783 r782 mr781
                                                     pat780 fender779
                                                     expr778)
                                              (call-with-values
                                                (lambda ()
                                                  (convert-pattern746
                                                    pat780
                                                    keys784))
                                                (lambda (p787 pvars786)
                                                  (if (not (distinct-bound-ids?127
                                                             (map car
                                                                  pvars786)))
                                                      (invalid-ids-error128
                                                        (map car pvars786)
                                                        pat780
                                                        '"pattern variable")
                                                      (if (not (andmap37
                                                                 (lambda (x788)
                                                                   (not (ellipsis?622
                                                                          (car x788))))
                                                                 pvars786))
                                                          (syntax-error
                                                            pat780
                                                            '"misplaced ellipsis in syntax-case pattern")
                                                          ((lambda (y789)
                                                             (build-application11
                                                               no-source3
                                                               (build-lambda29
                                                                 no-source3
                                                                 (list
                                                                   y789)
                                                                 '#f
                                                                 (cons
                                                                   'if
                                                                   (cons
                                                                     ((lambda (tmp790)
                                                                        ((lambda (tmp791)
                                                                           (if tmp791
                                                                               (apply
                                                                                 (lambda ()
                                                                                   y789)
                                                                                 tmp791)
                                                                               (cons
                                                                                 'if
                                                                                 (cons
                                                                                   (build-lexical-reference26
                                                                                     no-source3
                                                                                     y789)
                                                                                   (cons
                                                                                     (build-dispatch-call747
                                                                                       pvars786
                                                                                       fender779
                                                                                       y789
                                                                                       r782
                                                                                       mr781)
                                                                                     (cons
                                                                                       (build-data31
                                                                                         no-source3
                                                                                         '#f)
                                                                                       '()))))))
                                                                          ($syntax-dispatch
                                                                            tmp790
                                                                            '#(atom
                                                                               #t))))
                                                                       fender779)
                                                                     (cons
                                                                       (build-dispatch-call747
                                                                         pvars786
                                                                         expr778
                                                                         (build-lexical-reference26
                                                                           no-source3
                                                                           y789)
                                                                         r782
                                                                         mr781)
                                                                       (cons
                                                                         (gen-syntax-case749
                                                                           x785
                                                                           keys784
                                                                           clauses783
                                                                           r782
                                                                           mr781)
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
                                                                       x785)
                                                                     (build-data31
                                                                       no-source3
                                                                       p787))))))
                                                            (gen-var120
                                                              '#(syntax-object
                                                                 tmp (top)
                                                                 ()))))))))]
                             [gen-syntax-case749 (lambda (x767 keys766
                                                          clauses765 r764
                                                          mr763)
                                                   (if (null? clauses765)
                                                       (build-application11
                                                         no-source3
                                                         (build-primref30
                                                           no-source3
                                                           'syntax-error)
                                                         (list
                                                           (build-lexical-reference26
                                                             no-source3
                                                             x767)))
                                                       ((lambda (tmp768)
                                                          ((lambda (tmp769)
                                                             (if tmp769
                                                                 (apply
                                                                   (lambda (pat771
                                                                            expr770)
                                                                     (if (if (id?118
                                                                               pat771)
                                                                             (if (not (bound-id-member?125
                                                                                        pat771
                                                                                        keys766))
                                                                                 (not (ellipsis?622
                                                                                        pat771))
                                                                                 '#f)
                                                                             '#f)
                                                                         (if (free-identifier=?
                                                                               pat771
                                                                               '#(syntax-object
                                                                                  _
                                                                                  (top)
                                                                                  ()))
                                                                             (chi613
                                                                               expr770
                                                                               r764
                                                                               mr763)
                                                                             ((lambda (label773
                                                                                       var772)
                                                                                (build-application11
                                                                                  no-source3
                                                                                  (build-lambda29
                                                                                    no-source3
                                                                                    (list
                                                                                      var772)
                                                                                    '#f
                                                                                    (chi613
                                                                                      (add-subst96
                                                                                        (make-full-rib107
                                                                                          (list
                                                                                            pat771)
                                                                                          (list
                                                                                            label773))
                                                                                        expr770)
                                                                                      (extend-env113
                                                                                        label773
                                                                                        (make-binding109
                                                                                          'syntax
                                                                                          (cons
                                                                                            var772
                                                                                            '0))
                                                                                        r764)
                                                                                      mr763))
                                                                                  (list
                                                                                    (build-lexical-reference26
                                                                                      no-source3
                                                                                      x767))))
                                                                               (gen-label108)
                                                                               (gen-var120
                                                                                 pat771)))
                                                                         (gen-clause748
                                                                           x767
                                                                           keys766
                                                                           (cdr clauses765)
                                                                           r764
                                                                           mr763
                                                                           pat771
                                                                           '#t
                                                                           expr770)))
                                                                   tmp769)
                                                                 ((lambda (tmp774)
                                                                    (if tmp774
                                                                        (apply
                                                                          (lambda (pat777
                                                                                   fender776
                                                                                   expr775)
                                                                            (gen-clause748
                                                                              x767
                                                                              keys766
                                                                              (cdr clauses765)
                                                                              r764
                                                                              mr763
                                                                              pat777
                                                                              fender776
                                                                              expr775))
                                                                          tmp774)
                                                                        (syntax-error
                                                                          (car clauses765)
                                                                          '"invalid syntax-case clause")))
                                                                   ($syntax-dispatch
                                                                     tmp768
                                                                     '(any any
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp768
                                                              '(any any))))
                                                         (car clauses765))))])
                     (lambda (e752 r751 mr750)
                       ((lambda (tmp753)
                          ((lambda (tmp754)
                             (if tmp754
                                 (apply
                                   (lambda (expr757 key756 m755)
                                     (if (andmap37
                                           (lambda (x759)
                                             (if (id?118 x759)
                                                 (not (ellipsis?622 x759))
                                                 '#f))
                                           key756)
                                         ((lambda (x760)
                                            (build-application11
                                              (syn->src86 e752)
                                              (build-lambda29
                                                no-source3
                                                (list x760)
                                                '#f
                                                (gen-syntax-case749 x760
                                                  key756 m755 r751 mr750))
                                              (list
                                                (chi613
                                                  expr757
                                                  r751
                                                  mr750))))
                                           (gen-var120
                                             '#(syntax-object tmp (top)
                                                ())))
                                         (syntax-error
                                           e752
                                           '"invalid literals list in")))
                                   tmp754)
                                 (syntax-error tmp753)))
                            ($syntax-dispatch
                              tmp753
                              '(_ any each-any . each-any))))
                         e752))))))
              ((lambda ()
                 (letrec* ([fresh-mark623 (lambda (x745 fm744)
                                            (if fm744
                                                (anti-mark92
                                                  (add-mark93 m x745))
                                                x745))]
                           [gen-syntax624 (lambda (src689 e688 r687 maps686
                                                   ellipsis?685 vec?684
                                                   fm683)
                                            (if (id?118 e688)
                                                ((lambda (label690)
                                                   ((lambda (b691)
                                                      (if (eq? (binding-type110
                                                                 b691)
                                                               'syntax)
                                                          (call-with-values
                                                            (lambda ()
                                                              ((lambda (var.lev694)
                                                                 (gen-ref625
                                                                   src689
                                                                   (car var.lev694)
                                                                   (cdr var.lev694)
                                                                   maps686))
                                                                (binding-value111
                                                                  b691)))
                                                            (lambda (var693
                                                                     maps692)
                                                              (values
                                                                (cons
                                                                  'ref
                                                                  (cons
                                                                    var693
                                                                    '()))
                                                                maps692)))
                                                          (if (ellipsis?685
                                                                e688)
                                                              (syntax-error
                                                                src689
                                                                '"misplaced ellipsis in syntax form")
                                                              (values
                                                                (cons
                                                                  'quote
                                                                  (cons
                                                                    e688
                                                                    '()))
                                                                maps686))))
                                                     (label->binding122
                                                       label690
                                                       r687)))
                                                  (id->label121 e688))
                                                ((lambda (tmp695)
                                                   ((lambda (tmp696)
                                                      (if (if tmp696
                                                              (apply
                                                                (lambda (dots698
                                                                         e697)
                                                                  (ellipsis?685
                                                                    dots698))
                                                                tmp696)
                                                              '#f)
                                                          (apply
                                                            (lambda (dots700
                                                                     e699)
                                                              (if vec?684
                                                                  (syntax-error
                                                                    src689
                                                                    '"misplaced ellipsis in syntax form")
                                                                  (gen-syntax624
                                                                    src689
                                                                    e699
                                                                    r687
                                                                    maps686
                                                                    (lambda (x701)
                                                                      '#f)
                                                                    '#f
                                                                    fm683)))
                                                            tmp696)
                                                          ((lambda (tmp702)
                                                             (if (if tmp702
                                                                     (apply
                                                                       (lambda (x705
                                                                                dots704
                                                                                y703)
                                                                         (ellipsis?685
                                                                           dots704))
                                                                       tmp702)
                                                                     '#f)
                                                                 (apply
                                                                   (lambda (x708
                                                                            dots707
                                                                            y706)
                                                                     ((letrec ([f712 (lambda (y714
                                                                                              k713)
                                                                                       ((lambda (tmp715)
                                                                                          ((lambda (tmp716)
                                                                                             (if tmp716
                                                                                                 (apply
                                                                                                   (lambda ()
                                                                                                     (k713
                                                                                                       maps686))
                                                                                                   tmp716)
                                                                                                 ((lambda (tmp717)
                                                                                                    (if (if tmp717
                                                                                                            (apply
                                                                                                              (lambda (dots719
                                                                                                                       y718)
                                                                                                                (ellipsis?685
                                                                                                                  dots719))
                                                                                                              tmp717)
                                                                                                            '#f)
                                                                                                        (apply
                                                                                                          (lambda (dots721
                                                                                                                   y720)
                                                                                                            (f712
                                                                                                              y720
                                                                                                              (lambda (maps722)
                                                                                                                (call-with-values
                                                                                                                  (lambda ()
                                                                                                                    (k713
                                                                                                                      (cons
                                                                                                                        '()
                                                                                                                        maps722)))
                                                                                                                  (lambda (x724
                                                                                                                           maps723)
                                                                                                                    (if (null?
                                                                                                                          (car maps723))
                                                                                                                        (syntax-error
                                                                                                                          src689
                                                                                                                          '"extra ellipsis in syntax form")
                                                                                                                        (values
                                                                                                                          (gen-mappend627
                                                                                                                            x724
                                                                                                                            (car maps723))
                                                                                                                          (cdr maps723))))))))
                                                                                                          tmp717)
                                                                                                        (call-with-values
                                                                                                          (lambda ()
                                                                                                            (gen-syntax624
                                                                                                              src689
                                                                                                              y714
                                                                                                              r687
                                                                                                              maps686
                                                                                                              ellipsis?685
                                                                                                              vec?684
                                                                                                              fm683))
                                                                                                          (lambda (y726
                                                                                                                   maps725)
                                                                                                            (call-with-values
                                                                                                              (lambda ()
                                                                                                                (k713
                                                                                                                  maps725))
                                                                                                              (lambda (x728
                                                                                                                       maps727)
                                                                                                                (values
                                                                                                                  (gen-append626
                                                                                                                    x728
                                                                                                                    y726)
                                                                                                                  maps727)))))))
                                                                                                   ($syntax-dispatch
                                                                                                     tmp715
                                                                                                     '(any .
                                                                                                           any)))))
                                                                                            ($syntax-dispatch
                                                                                              tmp715
                                                                                              '())))
                                                                                         y714))])
                                                                        f712)
                                                                       y706
                                                                       (lambda (maps709)
                                                                         (call-with-values
                                                                           (lambda ()
                                                                             (gen-syntax624
                                                                               src689
                                                                               x708
                                                                               r687
                                                                               (cons
                                                                                 '()
                                                                                 maps709)
                                                                               ellipsis?685
                                                                               '#f
                                                                               fm683))
                                                                           (lambda (x711
                                                                                    maps710)
                                                                             (if (null?
                                                                                   (car maps710))
                                                                                 (syntax-error
                                                                                   src689
                                                                                   '"extra ellipsis in syntax form")
                                                                                 (values
                                                                                   (gen-map628
                                                                                     x711
                                                                                     (car maps710))
                                                                                   (cdr maps710))))))))
                                                                   tmp702)
                                                                 ((lambda (tmp729)
                                                                    (if tmp729
                                                                        (apply
                                                                          (lambda (x731
                                                                                   y730)
                                                                            (call-with-values
                                                                              (lambda ()
                                                                                (gen-syntax624
                                                                                  src689
                                                                                  x731
                                                                                  r687
                                                                                  maps686
                                                                                  ellipsis?685
                                                                                  '#f
                                                                                  fm683))
                                                                              (lambda (xnew733
                                                                                       maps732)
                                                                                (call-with-values
                                                                                  (lambda ()
                                                                                    (gen-syntax624
                                                                                      src689
                                                                                      y730
                                                                                      r687
                                                                                      maps732
                                                                                      ellipsis?685
                                                                                      vec?684
                                                                                      fm683))
                                                                                  (lambda (ynew735
                                                                                           maps734)
                                                                                    (values
                                                                                      (gen-cons629
                                                                                        e688
                                                                                        x731
                                                                                        y730
                                                                                        xnew733
                                                                                        ynew735)
                                                                                      maps734))))))
                                                                          tmp729)
                                                                        ((lambda (tmp736)
                                                                           (if tmp736
                                                                               (apply
                                                                                 (lambda (x1738
                                                                                          x2737)
                                                                                   ((lambda (ls740)
                                                                                      (call-with-values
                                                                                        (lambda ()
                                                                                          (gen-syntax624
                                                                                            src689
                                                                                            ls740
                                                                                            r687
                                                                                            maps686
                                                                                            ellipsis?685
                                                                                            '#t
                                                                                            fm683))
                                                                                        (lambda (lsnew742
                                                                                                 maps741)
                                                                                          (values
                                                                                            (gen-vector630
                                                                                              e688
                                                                                              ls740
                                                                                              lsnew742)
                                                                                            maps741))))
                                                                                     (cons
                                                                                       x1738
                                                                                       x2737)))
                                                                                 tmp736)
                                                                               ((lambda (tmp743)
                                                                                  (if (if tmp743
                                                                                          (apply
                                                                                            (lambda ()
                                                                                              vec?684)
                                                                                            tmp743)
                                                                                          '#f)
                                                                                      (apply
                                                                                        (lambda ()
                                                                                          (values
                                                                                            ''()
                                                                                            maps686))
                                                                                        tmp743)
                                                                                      (values
                                                                                        (cons
                                                                                          'quote
                                                                                          (cons
                                                                                            e688
                                                                                            '()))
                                                                                        maps686)))
                                                                                 ($syntax-dispatch
                                                                                   tmp695
                                                                                   '()))))
                                                                          ($syntax-dispatch
                                                                            tmp695
                                                                            '#(vector
                                                                               (any .
                                                                                    each-any))))))
                                                                   ($syntax-dispatch
                                                                     tmp695
                                                                     '(any .
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp695
                                                              '(any any
                                                                    .
                                                                    any)))))
                                                     ($syntax-dispatch
                                                       tmp695
                                                       '(any any))))
                                                  e688)))]
                           [gen-ref625 (lambda (src677 var676 level675
                                                maps674)
                                         (if (= level675 '0)
                                             (values var676 maps674)
                                             (if (null? maps674)
                                                 (syntax-error
                                                   src677
                                                   '"missing ellipsis in syntax form")
                                                 (call-with-values
                                                   (lambda ()
                                                     (gen-ref625
                                                       src677
                                                       var676
                                                       (- level675 '1)
                                                       (cdr maps674)))
                                                   (lambda (outer-var679
                                                            outer-maps678)
                                                     ((lambda (t680)
                                                        (if t680
                                                            ((lambda (b681)
                                                               (values
                                                                 (cdr b681)
                                                                 maps674))
                                                              t680)
                                                            ((lambda (inner-var682)
                                                               (values
                                                                 inner-var682
                                                                 (cons
                                                                   (cons
                                                                     (cons
                                                                       outer-var679
                                                                       inner-var682)
                                                                     (car maps674))
                                                                   outer-maps678)))
                                                              (gen-var120
                                                                '#(syntax-object
                                                                   tmp
                                                                   (top)
                                                                   ())))))
                                                       (assq
                                                         outer-var679
                                                         (car maps674))))))))]
                           [gen-append626 (lambda (x673 y672)
                                            (if (equal? y672 ''())
                                                x673
                                                (cons
                                                  'append
                                                  (cons
                                                    x673
                                                    (cons y672 '())))))]
                           [gen-mappend627 (lambda (e671 map-env670)
                                             (cons
                                               'apply
                                               (cons
                                                 '(primitive append)
                                                 (cons
                                                   (gen-map628
                                                     e671
                                                     map-env670)
                                                   '()))))]
                           [gen-map628 (lambda (e663 map-env662)
                                         ((lambda (formals666 actuals665)
                                            (if (eq? (car e663) 'ref)
                                                (car actuals665)
                                                (if (andmap37
                                                      (lambda (x667)
                                                        (if (eq? (car x667)
                                                                 'ref)
                                                            (memq
                                                              (cadr x667)
                                                              formals666)
                                                            '#f))
                                                      (cdr e663))
                                                    (cons
                                                      'map
                                                      (cons
                                                        (cons
                                                          'primitive
                                                          (cons
                                                            (car e663)
                                                            '()))
                                                        (append
                                                          (map ((lambda (r668)
                                                                  (lambda (x669)
                                                                    (cdr (assq
                                                                           (cadr
                                                                             x669)
                                                                           r668))))
                                                                 (map cons
                                                                      formals666
                                                                      actuals665))
                                                               (cdr e663))
                                                          '())))
                                                    (cons
                                                      'map
                                                      (cons
                                                        (cons
                                                          'lambda
                                                          (cons
                                                            formals666
                                                            (cons
                                                              e663
                                                              '())))
                                                        (append
                                                          actuals665
                                                          '()))))))
                                           (map cdr map-env662)
                                           (map (lambda (x664)
                                                  (cons
                                                    'ref
                                                    (cons (car x664) '())))
                                                map-env662)))]
                           [gen-cons629 (lambda (e658 x657 y656 xnew655
                                                 ynew654)
                                          ((lambda (t659)
                                             (if (memv t659 '(quote))
                                                 (if (eq? (car xnew655)
                                                          'quote)
                                                     ((lambda (xnew661
                                                               ynew660)
                                                        (if (if (eq? xnew661
                                                                     x657)
                                                                (eq? ynew660
                                                                     y656)
                                                                '#f)
                                                            (cons
                                                              'quote
                                                              (cons
                                                                e658
                                                                '()))
                                                            (cons
                                                              'quote
                                                              (cons
                                                                (cons
                                                                  xnew661
                                                                  ynew660)
                                                                '()))))
                                                       (cadr xnew655)
                                                       (cadr ynew654))
                                                     (if (eq? (cadr
                                                                ynew654)
                                                              '())
                                                         (cons
                                                           'list
                                                           (cons
                                                             xnew655
                                                             '()))
                                                         (cons
                                                           'cons
                                                           (cons
                                                             xnew655
                                                             (cons
                                                               ynew654
                                                               '())))))
                                                 (if (memv t659 '(list))
                                                     (cons
                                                       'list
                                                       (cons
                                                         xnew655
                                                         (append
                                                           (cdr ynew654)
                                                           '())))
                                                     (cons
                                                       'cons
                                                       (cons
                                                         xnew655
                                                         (cons
                                                           ynew654
                                                           '()))))))
                                            (car ynew654)))]
                           [gen-vector630 (lambda (e653 ls652 lsnew651)
                                            (if (eq? (car lsnew651) 'quote)
                                                (if (eq? (cadr lsnew651)
                                                         ls652)
                                                    (cons
                                                      'quote
                                                      (cons e653 '()))
                                                    (cons
                                                      'quote
                                                      (cons
                                                        (list->vector
                                                          (cadr lsnew651))
                                                        '())))
                                                (if (eq? (car lsnew651)
                                                         'list)
                                                    (cons
                                                      'vector
                                                      (append
                                                        (cdr lsnew651)
                                                        '()))
                                                    (cons
                                                      'list->vector
                                                      (cons
                                                        lsnew651
                                                        '())))))]
                           [regen631 (lambda (x648)
                                       ((lambda (t649)
                                          (if (memv t649 '(ref))
                                              (build-lexical-reference26
                                                no-source3
                                                (cadr x648))
                                              (if (memv t649 '(primitive))
                                                  (build-primref30
                                                    no-source3
                                                    (cadr x648))
                                                  (if (memv t649 '(quote))
                                                      (build-data31
                                                        no-source3
                                                        (cadr x648))
                                                      (if (memv
                                                            t649
                                                            '(lambda))
                                                          (build-lambda29
                                                            no-source3
                                                            (cadr x648)
                                                            '#f
                                                            (regen631
                                                              (caddr
                                                                x648)))
                                                          (if (memv
                                                                t649
                                                                '(map))
                                                              ((lambda (ls650)
                                                                 (build-application11
                                                                   no-source3
                                                                   (build-primref30
                                                                     no-source3
                                                                     'map)
                                                                   ls650))
                                                                (map regen631
                                                                     (cdr x648)))
                                                              (build-application11
                                                                no-source3
                                                                (build-primref30
                                                                  no-source3
                                                                  (car x648))
                                                                (map regen631
                                                                     (cdr x648)))))))))
                                         (car x648)))])
                   (begin
                     (global-extend9
                       'core
                       'syntax
                       (lambda (e642 r641 mr640)
                         ((lambda (tmp643)
                            ((lambda (tmp644)
                               (if tmp644
                                   (apply
                                     (lambda (x645)
                                       (call-with-values
                                         (lambda ()
                                           (gen-syntax624 e642 x645 r641
                                             '() ellipsis?622 '#f '#f))
                                         (lambda (e647 maps646)
                                           (regen631 e647))))
                                     tmp644)
                                   (syntax-error tmp643)))
                              ($syntax-dispatch tmp643 '(_ any))))
                           e642)))
                     (global-extend9
                       'core
                       'fresh-syntax
                       (lambda (e634 r633 mr632)
                         ((lambda (tmp635)
                            ((lambda (tmp636)
                               (if tmp636
                                   (apply
                                     (lambda (x637)
                                       (call-with-values
                                         (lambda ()
                                           (gen-syntax624 e634 x637 r633
                                             '() ellipsis?622 '#f
                                             (gen-mark90)))
                                         (lambda (e639 maps638)
                                           (regen631 e639))))
                                     tmp636)
                                   (syntax-error tmp635)))
                              ($syntax-dispatch tmp635 '(_ any))))
                           e634)))))))))))
       (set! $syntax-dispatch
         (lambda (e532 p531)
           (letrec* ([join-wraps533 (lambda (m1*603 s1*602 e601)
                                      (letrec* ([cancel604 (lambda (ls1608
                                                                    ls2607)
                                                             ((letrec ([f609 (lambda (x611
                                                                                      ls1610)
                                                                               (if (null?
                                                                                     ls1610)
                                                                                   (cdr ls2607)
                                                                                   (cons
                                                                                     x611
                                                                                     (f609
                                                                                       (car ls1610)
                                                                                       (cdr ls1610)))))])
                                                                f609)
                                                               (car ls1608)
                                                               (cdr ls1608)))])
                                        ((lambda (m2*606 s2*605)
                                           (if (if (not (null? m1*603))
                                                   (if (not (null? m2*606))
                                                       (eq? (car m2*606)
                                                            the-anti-mark91)
                                                       '#f)
                                                   '#f)
                                               (values
                                                 (cancel604 m1*603 m2*606)
                                                 (cancel604 s1*602 s2*605))
                                               (values
                                                 (append m1*603 m2*606)
                                                 (append s1*602 s2*605))))
                                          (syntax-object-mark*80 e601)
                                          (syntax-object-subst*81 e601))))]
                     [wrap534 (lambda (m*598 s*597 e596)
                                (if (syntax-object?78 e596)
                                    (call-with-values
                                      (lambda ()
                                        (join-wraps533 m*598 s*597 e596))
                                      (lambda (m*600 s*599)
                                        (make-syntax-object77
                                          (syntax-object-expression79 e596)
                                          m*600
                                          s*599)))
                                    (make-syntax-object77
                                      e596
                                      m*598
                                      s*597)))]
                     [match-each535 (lambda (e591 p590 m*589 s*588)
                                      (if (pair? e591)
                                          ((lambda (first592)
                                             (if first592
                                                 ((lambda (rest593)
                                                    (if rest593
                                                        (cons
                                                          first592
                                                          rest593)
                                                        '#f))
                                                   (match-each535
                                                     (cdr e591)
                                                     p590
                                                     m*589
                                                     s*588))
                                                 '#f))
                                            (match541 (car e591) p590 m*589
                                              s*588 '()))
                                          (if (null? e591)
                                              '()
                                              (if (syntax-object?78 e591)
                                                  (call-with-values
                                                    (lambda ()
                                                      (join-wraps533
                                                        m*589
                                                        s*588
                                                        e591))
                                                    (lambda (m*595 s*594)
                                                      (match-each535
                                                        (syntax-object-expression79
                                                          e591)
                                                        p590
                                                        m*595
                                                        s*594)))
                                                  (if (annotation?4 e591)
                                                      (match-each535
                                                        (annotation-expression5
                                                          e591)
                                                        p590
                                                        m*589
                                                        s*588)
                                                      '#f)))))]
                     [match-each+536 (lambda (e577 x-pat576 y-pat575
                                              z-pat574 m*573 s*572 r571)
                                       ((letrec ([f578 (lambda (e581 m*580
                                                                s*579)
                                                         (if (pair? e581)
                                                             (call-with-values
                                                               (lambda ()
                                                                 (f578
                                                                   (cdr e581)
                                                                   m*580
                                                                   s*579))
                                                               (lambda (xr*584
                                                                        y-pat583
                                                                        r582)
                                                                 (if r582
                                                                     (if (null?
                                                                           y-pat583)
                                                                         ((lambda (xr585)
                                                                            (if xr585
                                                                                (values
                                                                                  (cons
                                                                                    xr585
                                                                                    xr*584)
                                                                                  y-pat583
                                                                                  r582)
                                                                                (values
                                                                                  '#f
                                                                                  '#f
                                                                                  '#f)))
                                                                           (match541
                                                                             (car e581)
                                                                             x-pat576
                                                                             m*580
                                                                             s*579
                                                                             '()))
                                                                         (values
                                                                           '()
                                                                           (cdr y-pat583)
                                                                           (match541
                                                                             (car e581)
                                                                             (car y-pat583)
                                                                             m*580
                                                                             s*579
                                                                             r582)))
                                                                     (values
                                                                       '#f
                                                                       '#f
                                                                       '#f))))
                                                             (if (syntax-object?78
                                                                   e581)
                                                                 (call-with-values
                                                                   (lambda ()
                                                                     (join-wraps533
                                                                       m*580
                                                                       s*579
                                                                       e581))
                                                                   (lambda (m*587
                                                                            s*586)
                                                                     (f578
                                                                       (syntax-object-expression79
                                                                         e581)
                                                                       m*587
                                                                       s*586)))
                                                                 (if (annotation?4
                                                                       e581)
                                                                     (f578
                                                                       (annotation-expression5
                                                                         e581)
                                                                       m*580
                                                                       s*579)
                                                                     (values
                                                                       '()
                                                                       y-pat575
                                                                       (match541
                                                                         e581
                                                                         z-pat574
                                                                         m*580
                                                                         s*579
                                                                         r571))))))])
                                          f578)
                                         e577
                                         m*573
                                         s*572))]
                     [match-each-any537 (lambda (e567 m*566 s*565)
                                          (if (pair? e567)
                                              ((lambda (l568)
                                                 (if l568
                                                     (cons
                                                       (wrap534
                                                         m*566
                                                         s*565
                                                         (car e567))
                                                       l568)
                                                     '#f))
                                                (match-each-any537
                                                  (cdr e567)
                                                  m*566
                                                  s*565))
                                              (if (null? e567)
                                                  '()
                                                  (if (syntax-object?78
                                                        e567)
                                                      (call-with-values
                                                        (lambda ()
                                                          (join-wraps533
                                                            m*566
                                                            s*565
                                                            e567))
                                                        (lambda (m*570
                                                                 s*569)
                                                          (match-each-any537
                                                            (syntax-object-expression79
                                                              e567)
                                                            m*570
                                                            s*569)))
                                                      (if (annotation?4
                                                            e567)
                                                          (match-each-any537
                                                            (annotation-expression5
                                                              e567)
                                                            m*566
                                                            s*565)
                                                          '#f)))))]
                     [match-empty538 (lambda (p563 r562)
                                       (if (null? p563)
                                           r562
                                           (if (eq? p563 '_)
                                               r562
                                               (if (eq? p563 'any)
                                                   (cons '() r562)
                                                   (if (pair? p563)
                                                       (match-empty538
                                                         (car p563)
                                                         (match-empty538
                                                           (cdr p563)
                                                           r562))
                                                       (if (eq? p563
                                                                'each-any)
                                                           (cons '() r562)
                                                           ((lambda (t564)
                                                              (if (memv
                                                                    t564
                                                                    '(each))
                                                                  (match-empty538
                                                                    (vector-ref
                                                                      p563
                                                                      '1)
                                                                    r562)
                                                                  (if (memv
                                                                        t564
                                                                        '(each+))
                                                                      (match-empty538
                                                                        (vector-ref
                                                                          p563
                                                                          '1)
                                                                        (match-empty538
                                                                          (reverse
                                                                            (vector-ref
                                                                              p563
                                                                              '2))
                                                                          (match-empty538
                                                                            (vector-ref
                                                                              p563
                                                                              '3)
                                                                            r562)))
                                                                      (if (memv
                                                                            t564
                                                                            '(free-id
                                                                               atom))
                                                                          r562
                                                                          (if (memv
                                                                                t564
                                                                                '(vector))
                                                                              (match-empty538
                                                                                (vector-ref
                                                                                  p563
                                                                                  '1)
                                                                                r562)
                                                                              (error-hook1
                                                                                '$syntax-dispatch
                                                                                '"invalid pattern"
                                                                                p563))))))
                                                             (vector-ref
                                                               p563
                                                               '0))))))))]
                     [combine539 (lambda (r*561 r560)
                                   (if (null? (car r*561))
                                       r560
                                       (cons
                                         (map car r*561)
                                         (combine539
                                           (map cdr r*561)
                                           r560))))]
                     [match*540 (lambda (e553 p552 m*551 s*550 r549)
                                  (if (null? p552)
                                      (if (null? e553) r549 '#f)
                                      (if (pair? p552)
                                          (if (pair? e553)
                                              (match541 (car e553)
                                                (car p552) m*551 s*550
                                                (match541 (cdr e553)
                                                  (cdr p552) m*551 s*550
                                                  r549))
                                              '#f)
                                          (if (eq? p552 'each-any)
                                              ((lambda (l554)
                                                 (if l554
                                                     (cons l554 r549)
                                                     '#f))
                                                (match-each-any537
                                                  e553
                                                  m*551
                                                  s*550))
                                              ((lambda (t555)
                                                 (if (memv t555 '(each))
                                                     (if (null? e553)
                                                         (match-empty538
                                                           (vector-ref
                                                             p552
                                                             '1)
                                                           r549)
                                                         ((lambda (r*556)
                                                            (if r*556
                                                                (combine539
                                                                  r*556
                                                                  r549)
                                                                '#f))
                                                           (match-each535
                                                             e553
                                                             (vector-ref
                                                               p552
                                                               '1)
                                                             m*551
                                                             s*550)))
                                                     (if (memv
                                                           t555
                                                           '(free-id))
                                                         (if (symbol? e553)
                                                             (if (free-id=?123
                                                                   (wrap534
                                                                     m*551
                                                                     s*550
                                                                     e553)
                                                                   (vector-ref
                                                                     p552
                                                                     '1))
                                                                 r549
                                                                 '#f)
                                                             '#f)
                                                         (if (memv
                                                               t555
                                                               '(each+))
                                                             (call-with-values
                                                               (lambda ()
                                                                 (match-each+536
                                                                   e553
                                                                   (vector-ref
                                                                     p552
                                                                     '1)
                                                                   (vector-ref
                                                                     p552
                                                                     '2)
                                                                   (vector-ref
                                                                     p552
                                                                     '3)
                                                                   m*551
                                                                   s*550
                                                                   r549))
                                                               (lambda (xr*559
                                                                        y-pat558
                                                                        r557)
                                                                 (if r557
                                                                     (if (null?
                                                                           y-pat558)
                                                                         (if (null?
                                                                               xr*559)
                                                                             (match-empty538
                                                                               (vector-ref
                                                                                 p552
                                                                                 '1)
                                                                               r557)
                                                                             (combine539
                                                                               xr*559
                                                                               r557))
                                                                         '#f)
                                                                     '#f)))
                                                             (if (memv
                                                                   t555
                                                                   '(atom))
                                                                 (if (equal?
                                                                       (vector-ref
                                                                         p552
                                                                         '1)
                                                                       (strip85
                                                                         e553
                                                                         m*551))
                                                                     r549
                                                                     '#f)
                                                                 (if (memv
                                                                       t555
                                                                       '(vector))
                                                                     (if (vector?
                                                                           e553)
                                                                         (match541
                                                                           (vector->list
                                                                             e553)
                                                                           (vector-ref
                                                                             p552
                                                                             '1)
                                                                           m*551
                                                                           s*550
                                                                           r549)
                                                                         '#f)
                                                                     (error-hook1
                                                                       '$syntax-dispatch
                                                                       '"invalid pattern"
                                                                       p552)))))))
                                                (vector-ref p552 '0))))))]
                     [match541 (lambda (e546 p545 m*544 s*543 r542)
                                 (if (not r542)
                                     '#f
                                     (if (eq? p545 '_)
                                         r542
                                         (if (eq? p545 'any)
                                             (cons
                                               (wrap534 m*544 s*543 e546)
                                               r542)
                                             (if (syntax-object?78 e546)
                                                 (call-with-values
                                                   (lambda ()
                                                     (join-wraps533
                                                       m*544
                                                       s*543
                                                       e546))
                                                   (lambda (m*548 s*547)
                                                     (match*540
                                                       (unannotate87
                                                         (syntax-object-expression79
                                                           e546))
                                                       p545 m*548 s*547
                                                       r542)))
                                                 (match*540
                                                   (unannotate87 e546) p545
                                                   m*544 s*543 r542))))))])
             (match541 e532 p531 '() '() '()))))
       ((lambda ()
          (letrec* ([arg-check512 (lambda (pred?530 x529 who528)
                                    (if (not (pred?530 x529))
                                        (error-hook1
                                          who528
                                          '"invalid argument"
                                          x529)
                                        (void)))])
            (begin
              (set! identifier? (lambda (x527) (id?118 x527)))
              (set! datum->syntax
                (lambda (id526 datum525)
                  (begin
                    (arg-check512 id?118 id526 'datum->syntax)
                    (make-syntax-object77
                      datum525
                      (syntax-object-mark*80 id526)
                      (syntax-object-subst*81 id526)))))
              (set! syntax->datum (lambda (x524) (strip85 x524 '())))
              (set! generate-temporaries
                (lambda (ls522)
                  (begin
                    (arg-check512 list? ls522 'generate-temporaries)
                    (map (lambda (x523)
                           (make-syntax-object77
                             (gensym-hook2)
                             top-mark*88
                             top-subst*95))
                         ls522))))
              (set! free-identifier=?
                (lambda (x521 y520)
                  (begin
                    (arg-check512 id?118 x521 'free-identifier=?)
                    (arg-check512 id?118 y520 'free-identifier=?)
                    (free-id=?123 x521 y520))))
              (set! bound-identifier=?
                (lambda (x519 y518)
                  (begin
                    (arg-check512 id?118 x519 'bound-identifier=?)
                    (arg-check512 id?118 y518 'bound-identifier=?)
                    (bound-id=?124 x519 y518))))
              (set! syntax-error
                (lambda (object515 . messages514)
                  (begin
                    (for-each
                      (lambda (x517)
                        (arg-check512 string? x517 'syntax-error))
                      messages514)
                    ((lambda (message516)
                       (error-hook1
                         '#f
                         message516
                         (strip85 object515 '())))
                      (if (null? messages514)
                          '"invalid syntax"
                          (apply string-append messages514))))))
              (set! make-variable-transformer
                (lambda (p513)
                  (begin
                    (arg-check512
                      procedure?
                      p513
                      'make-variable-transformer)
                    (cons 'macro! p513))))))))
       (global-extend9
         'macro
         'with-syntax
         (lambda (x492)
           ((lambda (tmp493)
              ((lambda (tmp494)
                 (if tmp494
                     (apply
                       (lambda (e1496 e2495)
                         (cons
                           '#(syntax-object begin (top) ())
                           (cons e1496 e2495)))
                       tmp494)
                     ((lambda (tmp498)
                        (if tmp498
                            (apply
                              (lambda (out502 in501 e1500 e2499)
                                (cons
                                  '#(syntax-object syntax-case (top) ())
                                  (cons
                                    in501
                                    (cons
                                      '#(syntax-object () (top) ())
                                      (cons
                                        (cons
                                          out502
                                          (cons
                                            (cons
                                              '#(syntax-object begin (top)
                                                 ())
                                              (cons e1500 e2499))
                                            '#(syntax-object () (top) ())))
                                        '#(syntax-object () (top) ()))))))
                              tmp498)
                            ((lambda (tmp504)
                               (if tmp504
                                   (apply
                                     (lambda (out508 in507 e1506 e2505)
                                       (cons
                                         '#(syntax-object syntax-case (top)
                                            ())
                                         (cons
                                           (cons
                                             '#(syntax-object list (top)
                                                ())
                                             in507)
                                           (cons
                                             '#(syntax-object () (top) ())
                                             (cons
                                               (cons
                                                 out508
                                                 (cons
                                                   (cons
                                                     '#(syntax-object begin
                                                        (top) ())
                                                     (cons e1506 e2505))
                                                   '#(syntax-object ()
                                                      (top) ())))
                                               '#(syntax-object () (top)
                                                  ()))))))
                                     tmp504)
                                   (syntax-error tmp493)))
                              ($syntax-dispatch
                                tmp493
                                '(_ #(each (any any)) any . each-any)))))
                       ($syntax-dispatch
                         tmp493
                         '(_ ((any any)) any . each-any)))))
                ($syntax-dispatch tmp493 '(_ () any . each-any))))
             x492)))
       (global-extend9
         'macro
         'syntax-rules
         (lambda (x466)
           (letrec* ([clause467 (lambda (y481)
                                  ((lambda (tmp482)
                                     ((lambda (tmp483)
                                        (if tmp483
                                            (apply
                                              (lambda (keyword486
                                                       pattern485
                                                       template484)
                                                (cons
                                                  (cons
                                                    '#(syntax-object dummy
                                                       (top) ())
                                                    pattern485)
                                                  (cons
                                                    (cons
                                                      '#(syntax-object
                                                         syntax (top) ())
                                                      (cons
                                                        template484
                                                        '#(syntax-object ()
                                                           (top) ())))
                                                    '#(syntax-object ()
                                                       (top) ()))))
                                              tmp483)
                                            ((lambda (tmp487)
                                               (if tmp487
                                                   (apply
                                                     (lambda (keyword491
                                                              pattern490
                                                              fender489
                                                              template488)
                                                       (cons
                                                         (cons
                                                           '#(syntax-object
                                                              dummy (top)
                                                              ())
                                                           pattern490)
                                                         (cons
                                                           fender489
                                                           (cons
                                                             (cons
                                                               '#(syntax-object
                                                                  syntax
                                                                  (top) ())
                                                               (cons
                                                                 template488
                                                                 '#(syntax-object
                                                                    ()
                                                                    (top)
                                                                    ())))
                                                             '#(syntax-object
                                                                () (top)
                                                                ())))))
                                                     tmp487)
                                                   (syntax-error x466)))
                                              ($syntax-dispatch
                                                tmp482
                                                '((any . any) any any)))))
                                       ($syntax-dispatch
                                         tmp482
                                         '((any . any) any))))
                                    y481))])
             ((lambda (tmp468)
                ((lambda (tmp469)
                   (if (if tmp469
                           (apply
                             (lambda (k471 cl470)
                               (andmap37 identifier? k471))
                             tmp469)
                           '#f)
                       (apply
                         (lambda (k474 cl473)
                           ((lambda (tmp475)
                              ((lambda (tmp477)
                                 (if tmp477
                                     (apply
                                       (lambda (cl478)
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
                                                   (cons k474 cl478)))
                                               '#(syntax-object () (top)
                                                  ())))))
                                       tmp477)
                                     (syntax-error tmp475)))
                                ($syntax-dispatch tmp475 'each-any)))
                             (map clause467 cl473)))
                         tmp469)
                       (syntax-error tmp468)))
                  ($syntax-dispatch tmp468 '(_ each-any . each-any))))
               x466))))
       (global-extend9
         'macro
         'or
         (lambda (x456)
           ((lambda (tmp457)
              ((lambda (tmp458)
                 (if tmp458
                     (apply
                       (lambda () '#(syntax-object #f (top) ()))
                       tmp458)
                     ((lambda (tmp459)
                        (if tmp459
                            (apply (lambda (e460) e460) tmp459)
                            ((lambda (tmp461)
                               (if tmp461
                                   (apply
                                     (lambda (e1464 e2463 e3462)
                                       (cons
                                         '#(syntax-object let (top) ())
                                         (cons
                                           (cons
                                             (cons
                                               '#(syntax-object t (top) ())
                                               (cons
                                                 e1464
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
                                                       (cons e2463 e3462))
                                                     '#(syntax-object ()
                                                        (top) ())))))
                                             '#(syntax-object () (top)
                                                ())))))
                                     tmp461)
                                   (syntax-error tmp457)))
                              ($syntax-dispatch
                                tmp457
                                '(_ any any . each-any)))))
                       ($syntax-dispatch tmp457 '(_ any)))))
                ($syntax-dispatch tmp457 '(_))))
             x456)))
       (global-extend9
         'macro
         'and
         (lambda (x446)
           ((lambda (tmp447)
              ((lambda (tmp448)
                 (if tmp448
                     (apply
                       (lambda (e1451 e2450 e3449)
                         (cons
                           '#(syntax-object if (top) ())
                           (cons
                             e1451
                             (cons
                               (cons
                                 '#(syntax-object and (top) ())
                                 (cons e2450 e3449))
                               '#(syntax-object (#f) (top) ())))))
                       tmp448)
                     ((lambda (tmp453)
                        (if tmp453
                            (apply (lambda (e454) e454) tmp453)
                            ((lambda (tmp455)
                               (if tmp455
                                   (apply
                                     (lambda ()
                                       '#(syntax-object #t (top) ()))
                                     tmp455)
                                   (syntax-error tmp447)))
                              ($syntax-dispatch tmp447 '(_)))))
                       ($syntax-dispatch tmp447 '(_ any)))))
                ($syntax-dispatch tmp447 '(_ any any . each-any))))
             x446)))
       (global-extend9
         'macro
         'let
         (lambda (x416)
           ((lambda (tmp417)
              ((lambda (tmp418)
                 (if (if tmp418
                         (apply
                           (lambda (x422 v421 e1420 e2419)
                             (andmap37 identifier? x422))
                           tmp418)
                         '#f)
                     (apply
                       (lambda (x427 v426 e1425 e2424)
                         (cons
                           (cons
                             '#(syntax-object lambda (top) ())
                             (cons x427 (cons e1425 e2424)))
                           v426))
                       tmp418)
                     ((lambda (tmp431)
                        (if (if tmp431
                                (apply
                                  (lambda (f436 x435 v434 e1433 e2432)
                                    (andmap37
                                      identifier?
                                      (cons f436 x435)))
                                  tmp431)
                                '#f)
                            (apply
                              (lambda (f442 x441 v440 e1439 e2438)
                                (cons
                                  (cons
                                    '#(syntax-object letrec (top) ())
                                    (cons
                                      (cons
                                        (cons
                                          f442
                                          (cons
                                            (cons
                                              '#(syntax-object lambda (top)
                                                 ())
                                              (cons
                                                x441
                                                (cons e1439 e2438)))
                                            '#(syntax-object () (top) ())))
                                        '#(syntax-object () (top) ()))
                                      (cons
                                        f442
                                        '#(syntax-object () (top) ()))))
                                  v440))
                              tmp431)
                            (syntax-error tmp417)))
                       ($syntax-dispatch
                         tmp417
                         '(_ any #(each (any any)) any . each-any)))))
                ($syntax-dispatch
                  tmp417
                  '(_ #(each (any any)) any . each-any))))
             x416)))
       (global-extend9
         'macro
         'let*
         (lambda (x385)
           ((lambda (tmp386)
              ((lambda (tmp387)
                 (if tmp387
                     (apply
                       (lambda (e1389 e2388)
                         (cons
                           '#(syntax-object let (top) ())
                           (cons
                             '#(syntax-object () (top) ())
                             (cons e1389 e2388))))
                       tmp387)
                     ((lambda (tmp391)
                        (if (if tmp391
                                (apply
                                  (lambda (x395 v394 e1393 e2392)
                                    (andmap37 identifier? x395))
                                  tmp391)
                                '#f)
                            (apply
                              (lambda (x400 v399 e1398 e2397)
                                ((letrec ([f403 (lambda (bindings404)
                                                  ((lambda (tmp405)
                                                     ((lambda (tmp406)
                                                        (if tmp406
                                                            (apply
                                                              (lambda (x408
                                                                       v407)
                                                                (cons
                                                                  '#(syntax-object
                                                                     let
                                                                     (top)
                                                                     ())
                                                                  (cons
                                                                    (cons
                                                                      (cons
                                                                        x408
                                                                        (cons
                                                                          v407
                                                                          '#(syntax-object
                                                                             ()
                                                                             (top)
                                                                             ())))
                                                                      '#(syntax-object
                                                                         ()
                                                                         (top)
                                                                         ()))
                                                                    (cons
                                                                      e1398
                                                                      e2397))))
                                                              tmp406)
                                                            ((lambda (tmp410)
                                                               (if tmp410
                                                                   (apply
                                                                     (lambda (x413
                                                                              v412
                                                                              rest411)
                                                                       ((lambda (tmp414)
                                                                          ((lambda (body415)
                                                                             (cons
                                                                               '#(syntax-object
                                                                                  let
                                                                                  (top)
                                                                                  ())
                                                                               (cons
                                                                                 (cons
                                                                                   (cons
                                                                                     x413
                                                                                     (cons
                                                                                       v412
                                                                                       '#(syntax-object
                                                                                          ()
                                                                                          (top)
                                                                                          ())))
                                                                                   '#(syntax-object
                                                                                      ()
                                                                                      (top)
                                                                                      ()))
                                                                                 (cons
                                                                                   body415
                                                                                   '#(syntax-object
                                                                                      ()
                                                                                      (top)
                                                                                      ())))))
                                                                            tmp414))
                                                                         (f403
                                                                           rest411)))
                                                                     tmp410)
                                                                   (syntax-error
                                                                     tmp405)))
                                                              ($syntax-dispatch
                                                                tmp405
                                                                '((any any)
                                                                   .
                                                                   any)))))
                                                       ($syntax-dispatch
                                                         tmp405
                                                         '((any any)))))
                                                    bindings404))])
                                   f403)
                                  (map (lambda (tmp402 tmp401)
                                         (cons
                                           tmp401
                                           (cons
                                             tmp402
                                             '#(syntax-object () (top)
                                                ()))))
                                       v399
                                       x400)))
                              tmp391)
                            (syntax-error tmp386)))
                       ($syntax-dispatch
                         tmp386
                         '(_ #(each (any any)) any . each-any)))))
                ($syntax-dispatch tmp386 '(_ () any . each-any))))
             x385)))
       (global-extend9
         'macro
         'cond
         (lambda (x342)
           ((lambda (tmp343)
              ((lambda (tmp344)
                 (if tmp344
                     (apply
                       (lambda (c1346 c2345)
                         ((letrec ([f348 (lambda (c1350 c2*349)
                                           ((lambda (tmp351)
                                              ((lambda (tmp352)
                                                 (if tmp352
                                                     (apply
                                                       (lambda ()
                                                         ((lambda (tmp353)
                                                            ((lambda (tmp354)
                                                               (if tmp354
                                                                   (apply
                                                                     (lambda (e1356
                                                                              e2355)
                                                                       (cons
                                                                         '#(syntax-object
                                                                            begin
                                                                            (top)
                                                                            ())
                                                                         (cons
                                                                           e1356
                                                                           e2355)))
                                                                     tmp354)
                                                                   ((lambda (tmp358)
                                                                      (if tmp358
                                                                          (apply
                                                                            (lambda (e0359)
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
                                                                                        e0359
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
                                                                            tmp358)
                                                                          ((lambda (tmp360)
                                                                             (if tmp360
                                                                                 (apply
                                                                                   (lambda (e0362
                                                                                            e1361)
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
                                                                                               e0362
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
                                                                                                   e1361
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
                                                                                   tmp360)
                                                                                 ((lambda (tmp363)
                                                                                    (if tmp363
                                                                                        (apply
                                                                                          (lambda (e0366
                                                                                                   e1365
                                                                                                   e2364)
                                                                                            (cons
                                                                                              '#(syntax-object
                                                                                                 if
                                                                                                 (top)
                                                                                                 ())
                                                                                              (cons
                                                                                                e0366
                                                                                                (cons
                                                                                                  (cons
                                                                                                    '#(syntax-object
                                                                                                       begin
                                                                                                       (top)
                                                                                                       ())
                                                                                                    (cons
                                                                                                      e1365
                                                                                                      e2364))
                                                                                                  '#(syntax-object
                                                                                                     ()
                                                                                                     (top)
                                                                                                     ())))))
                                                                                          tmp363)
                                                                                        (syntax-error
                                                                                          x342)))
                                                                                   ($syntax-dispatch
                                                                                     tmp353
                                                                                     '(any any
                                                                                           .
                                                                                           each-any)))))
                                                                            ($syntax-dispatch
                                                                              tmp353
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
                                                                                             add-subst
                                                                                             top-subst*
                                                                                             same-marks?
                                                                                             add-mark
                                                                                             anti-mark
                                                                                             the-anti-mark
                                                                                             gen-mark
                                                                                             top-marked?
                                                                                             top-mark*
                                                                                             unannotate
                                                                                             syn->src
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
                                                                                             "i")))))
                                                                                    any)))))
                                                                     ($syntax-dispatch
                                                                       tmp353
                                                                       '(any)))))
                                                              ($syntax-dispatch
                                                                tmp353
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
                                                                           add-subst
                                                                           top-subst*
                                                                           same-marks?
                                                                           add-mark
                                                                           anti-mark
                                                                           the-anti-mark
                                                                           gen-mark
                                                                           top-marked?
                                                                           top-mark*
                                                                           unannotate
                                                                           syn->src
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
                                                                           "i")))))
                                                                   any
                                                                   .
                                                                   each-any))))
                                                           c1350))
                                                       tmp352)
                                                     ((lambda (tmp368)
                                                        (if tmp368
                                                            (apply
                                                              (lambda (c2370
                                                                       c3369)
                                                                ((lambda (tmp371)
                                                                   ((lambda (rest373)
                                                                      ((lambda (tmp374)
                                                                         ((lambda (tmp375)
                                                                            (if tmp375
                                                                                (apply
                                                                                  (lambda (e0376)
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
                                                                                              e0376
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
                                                                                                  rest373
                                                                                                  '#(syntax-object
                                                                                                     ()
                                                                                                     (top)
                                                                                                     ())))))
                                                                                          '#(syntax-object
                                                                                             ()
                                                                                             (top)
                                                                                             ())))))
                                                                                  tmp375)
                                                                                ((lambda (tmp377)
                                                                                   (if tmp377
                                                                                       (apply
                                                                                         (lambda (e0379
                                                                                                  e1378)
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
                                                                                                     e0379
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
                                                                                                         e1378
                                                                                                         '#(syntax-object
                                                                                                            (t)
                                                                                                            (top)
                                                                                                            ()))
                                                                                                       (cons
                                                                                                         rest373
                                                                                                         '#(syntax-object
                                                                                                            ()
                                                                                                            (top)
                                                                                                            ())))))
                                                                                                 '#(syntax-object
                                                                                                    ()
                                                                                                    (top)
                                                                                                    ())))))
                                                                                         tmp377)
                                                                                       ((lambda (tmp380)
                                                                                          (if tmp380
                                                                                              (apply
                                                                                                (lambda (e0383
                                                                                                         e1382
                                                                                                         e2381)
                                                                                                  (cons
                                                                                                    '#(syntax-object
                                                                                                       if
                                                                                                       (top)
                                                                                                       ())
                                                                                                    (cons
                                                                                                      e0383
                                                                                                      (cons
                                                                                                        (cons
                                                                                                          '#(syntax-object
                                                                                                             begin
                                                                                                             (top)
                                                                                                             ())
                                                                                                          (cons
                                                                                                            e1382
                                                                                                            e2381))
                                                                                                        (cons
                                                                                                          rest373
                                                                                                          '#(syntax-object
                                                                                                             ()
                                                                                                             (top)
                                                                                                             ()))))))
                                                                                                tmp380)
                                                                                              (syntax-error
                                                                                                x342)))
                                                                                         ($syntax-dispatch
                                                                                           tmp374
                                                                                           '(any any
                                                                                                 .
                                                                                                 each-any)))))
                                                                                  ($syntax-dispatch
                                                                                    tmp374
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
                                                                                                   add-subst
                                                                                                   top-subst*
                                                                                                   same-marks?
                                                                                                   add-mark
                                                                                                   anti-mark
                                                                                                   the-anti-mark
                                                                                                   gen-mark
                                                                                                   top-marked?
                                                                                                   top-mark*
                                                                                                   unannotate
                                                                                                   syn->src
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
                                                                                                   "i")))))
                                                                                          any)))))
                                                                           ($syntax-dispatch
                                                                             tmp374
                                                                             '(any))))
                                                                        c1350))
                                                                     tmp371))
                                                                  (f348
                                                                    c2370
                                                                    c3369)))
                                                              tmp368)
                                                            (syntax-error
                                                              tmp351)))
                                                       ($syntax-dispatch
                                                         tmp351
                                                         '(any .
                                                               each-any)))))
                                                ($syntax-dispatch
                                                  tmp351
                                                  '())))
                                             c2*349))])
                            f348)
                           c1346
                           c2345))
                       tmp344)
                     (syntax-error tmp343)))
                ($syntax-dispatch tmp343 '(_ any . each-any))))
             x342)))
       (global-extend9
         'macro
         'do
         (lambda (orig-x307)
           ((lambda (tmp308)
              ((lambda (tmp309)
                 (if tmp309
                     (apply
                       (lambda (var315 init314 step313 e0312 e1311 c310)
                         ((lambda (tmp316)
                            ((lambda (tmp325)
                               (if tmp325
                                   (apply
                                     (lambda (step326)
                                       ((lambda (tmp327)
                                          ((lambda (tmp329)
                                             (if tmp329
                                                 (apply
                                                   (lambda ()
                                                     (cons
                                                       '#(syntax-object let
                                                          (top) ())
                                                       (cons
                                                         '#(syntax-object
                                                            do (top) ())
                                                         (cons
                                                           (map (lambda (tmp331
                                                                         tmp330)
                                                                  (cons
                                                                    tmp330
                                                                    (cons
                                                                      tmp331
                                                                      '#(syntax-object
                                                                         ()
                                                                         (top)
                                                                         ()))))
                                                                init314
                                                                var315)
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
                                                                     e0312
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
                                                                       c310
                                                                       (cons
                                                                         (cons
                                                                           '#(syntax-object
                                                                              do
                                                                              (top)
                                                                              ())
                                                                           step326)
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
                                                   tmp329)
                                                 ((lambda (tmp334)
                                                    (if tmp334
                                                        (apply
                                                          (lambda (e1336
                                                                   e2335)
                                                            (cons
                                                              '#(syntax-object
                                                                 let (top)
                                                                 ())
                                                              (cons
                                                                '#(syntax-object
                                                                   do (top)
                                                                   ())
                                                                (cons
                                                                  (map (lambda (tmp338
                                                                                tmp337)
                                                                         (cons
                                                                           tmp337
                                                                           (cons
                                                                             tmp338
                                                                             '#(syntax-object
                                                                                ()
                                                                                (top)
                                                                                ()))))
                                                                       init314
                                                                       var315)
                                                                  (cons
                                                                    (cons
                                                                      '#(syntax-object
                                                                         if
                                                                         (top)
                                                                         ())
                                                                      (cons
                                                                        e0312
                                                                        (cons
                                                                          (cons
                                                                            '#(syntax-object
                                                                               begin
                                                                               (top)
                                                                               ())
                                                                            (cons
                                                                              e1336
                                                                              e2335))
                                                                          (cons
                                                                            (cons
                                                                              '#(syntax-object
                                                                                 begin
                                                                                 (top)
                                                                                 ())
                                                                              (append
                                                                                c310
                                                                                (cons
                                                                                  (cons
                                                                                    '#(syntax-object
                                                                                       do
                                                                                       (top)
                                                                                       ())
                                                                                    step326)
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
                                                          tmp334)
                                                        (syntax-error
                                                          tmp327)))
                                                   ($syntax-dispatch
                                                     tmp327
                                                     '(any . each-any)))))
                                            ($syntax-dispatch tmp327 '())))
                                         e1311))
                                     tmp325)
                                   (syntax-error tmp316)))
                              ($syntax-dispatch tmp316 'each-any)))
                           (map (lambda (v320 s319)
                                  ((lambda (tmp321)
                                     ((lambda (tmp322)
                                        (if tmp322
                                            (apply (lambda () v320) tmp322)
                                            ((lambda (tmp323)
                                               (if tmp323
                                                   (apply
                                                     (lambda (e324) e324)
                                                     tmp323)
                                                   (syntax-error
                                                     orig-x307)))
                                              ($syntax-dispatch
                                                tmp321
                                                '(any)))))
                                       ($syntax-dispatch tmp321 '())))
                                    s319))
                                var315
                                step313)))
                       tmp309)
                     (syntax-error tmp308)))
                ($syntax-dispatch
                  tmp308
                  '(_ #(each (any any . any))
                      (any . each-any)
                      .
                      each-any))))
             orig-x307)))
       (global-extend9
         'macro
         'quasiquote
         ((lambda ()
            (letrec* ([quasilist*203 (lambda (x304 y303)
                                       ((letrec ([f305 (lambda (x306)
                                                         (if (null? x306)
                                                             y303
                                                             (quasicons204
                                                               (car x306)
                                                               (f305
                                                                 (cdr x306)))))])
                                          f305)
                                         x304))]
                      [quasicons204 (lambda (x290 y289)
                                      ((lambda (tmp291)
                                         ((lambda (tmp292)
                                            (if tmp292
                                                (apply
                                                  (lambda (x294 y293)
                                                    ((lambda (tmp295)
                                                       ((lambda (tmp296)
                                                          (if tmp296
                                                              (apply
                                                                (lambda (dy297)
                                                                  ((lambda (tmp298)
                                                                     ((lambda (tmp299)
                                                                        (if tmp299
                                                                            (apply
                                                                              (lambda (dx300)
                                                                                (cons
                                                                                  '#(syntax-object
                                                                                     quote
                                                                                     (top)
                                                                                     ())
                                                                                  (cons
                                                                                    (cons
                                                                                      dx300
                                                                                      dy297)
                                                                                    '#(syntax-object
                                                                                       ()
                                                                                       (top)
                                                                                       ()))))
                                                                              tmp299)
                                                                            (if (null?
                                                                                  dy297)
                                                                                (cons
                                                                                  '#(syntax-object
                                                                                     list
                                                                                     (top)
                                                                                     ())
                                                                                  (cons
                                                                                    x294
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
                                                                                    x294
                                                                                    (cons
                                                                                      y293
                                                                                      '#(syntax-object
                                                                                         ()
                                                                                         (top)
                                                                                         ())))))))
                                                                       ($syntax-dispatch
                                                                         tmp298
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
                                                                                    add-subst
                                                                                    top-subst*
                                                                                    same-marks?
                                                                                    add-mark
                                                                                    anti-mark
                                                                                    the-anti-mark
                                                                                    gen-mark
                                                                                    top-marked?
                                                                                    top-mark*
                                                                                    unannotate
                                                                                    syn->src
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
                                                                                    "i")))))
                                                                            any))))
                                                                    x294))
                                                                tmp296)
                                                              ((lambda (tmp301)
                                                                 (if tmp301
                                                                     (apply
                                                                       (lambda (stuff302)
                                                                         (cons
                                                                           '#(syntax-object
                                                                              list
                                                                              (top)
                                                                              ())
                                                                           (cons
                                                                             x294
                                                                             stuff302)))
                                                                       tmp301)
                                                                     (cons
                                                                       '#(syntax-object
                                                                          cons
                                                                          (top)
                                                                          ())
                                                                       (cons
                                                                         x294
                                                                         (cons
                                                                           y293
                                                                           '#(syntax-object
                                                                              ()
                                                                              (top)
                                                                              ()))))))
                                                                ($syntax-dispatch
                                                                  tmp295
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
                                                                             add-subst
                                                                             top-subst*
                                                                             same-marks?
                                                                             add-mark
                                                                             anti-mark
                                                                             the-anti-mark
                                                                             gen-mark
                                                                             top-marked?
                                                                             top-mark*
                                                                             unannotate
                                                                             syn->src
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
                                                                             "i")))))
                                                                     .
                                                                     any)))))
                                                         ($syntax-dispatch
                                                           tmp295
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
                                                                      add-subst
                                                                      top-subst*
                                                                      same-marks?
                                                                      add-mark
                                                                      anti-mark
                                                                      the-anti-mark
                                                                      gen-mark
                                                                      top-marked?
                                                                      top-mark*
                                                                      unannotate
                                                                      syn->src
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
                                                                      "i")))))
                                                              any))))
                                                      y293))
                                                  tmp292)
                                                (syntax-error tmp291)))
                                           ($syntax-dispatch
                                             tmp291
                                             '(any any))))
                                        (list x290 y289)))]
                      [quasiappend205 (lambda (x277 y276)
                                        ((lambda (ls284)
                                           (if (null? ls284)
                                               '#(syntax-object '() (top)
                                                  ())
                                               (if (null? (cdr ls284))
                                                   (car ls284)
                                                   ((lambda (tmp285)
                                                      ((lambda (tmp286)
                                                         (if tmp286
                                                             (apply
                                                               (lambda (p287)
                                                                 (cons
                                                                   '#(syntax-object
                                                                      append
                                                                      (top)
                                                                      ())
                                                                   p287))
                                                               tmp286)
                                                             (syntax-error
                                                               tmp285)))
                                                        ($syntax-dispatch
                                                          tmp285
                                                          'each-any)))
                                                     ls284))))
                                          ((letrec ([f278 (lambda (x279)
                                                            (if (null?
                                                                  x279)
                                                                ((lambda (tmp280)
                                                                   ((lambda (tmp281)
                                                                      (if tmp281
                                                                          (apply
                                                                            (lambda ()
                                                                              '())
                                                                            tmp281)
                                                                          (list
                                                                            y276)))
                                                                     ($syntax-dispatch
                                                                       tmp280
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
                                                                                  add-subst
                                                                                  top-subst*
                                                                                  same-marks?
                                                                                  add-mark
                                                                                  anti-mark
                                                                                  the-anti-mark
                                                                                  gen-mark
                                                                                  top-marked?
                                                                                  top-mark*
                                                                                  unannotate
                                                                                  syn->src
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
                                                                                  "i")))))
                                                                          ()))))
                                                                  y276)
                                                                ((lambda (tmp282)
                                                                   ((lambda (tmp283)
                                                                      (if tmp283
                                                                          (apply
                                                                            (lambda ()
                                                                              (f278
                                                                                (cdr x279)))
                                                                            tmp283)
                                                                          (cons
                                                                            (car x279)
                                                                            (f278
                                                                              (cdr x279)))))
                                                                     ($syntax-dispatch
                                                                       tmp282
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
                                                                                  add-subst
                                                                                  top-subst*
                                                                                  same-marks?
                                                                                  add-mark
                                                                                  anti-mark
                                                                                  the-anti-mark
                                                                                  gen-mark
                                                                                  top-marked?
                                                                                  top-mark*
                                                                                  unannotate
                                                                                  syn->src
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
                                                                                  "i")))))
                                                                          ()))))
                                                                  (car x279))))])
                                             f278)
                                            x277)))]
                      [quasivector206 (lambda (x254)
                                        ((lambda (tmp255)
                                           ((lambda (pat-x256)
                                              ((lambda (tmp257)
                                                 ((lambda (tmp258)
                                                    (if tmp258
                                                        (apply
                                                          (lambda (x259)
                                                            (cons
                                                              '#(syntax-object
                                                                 quote
                                                                 (top) ())
                                                              (cons
                                                                (list->vector
                                                                  x259)
                                                                '#(syntax-object
                                                                   () (top)
                                                                   ()))))
                                                          tmp258)
                                                        ((letrec ([f262 (lambda (x264
                                                                                 k263)
                                                                          ((lambda (tmp265)
                                                                             ((lambda (tmp266)
                                                                                (if tmp266
                                                                                    (apply
                                                                                      (lambda (x267)
                                                                                        (k263
                                                                                          (map (lambda (tmp268)
                                                                                                 (cons
                                                                                                   '#(syntax-object
                                                                                                      quote
                                                                                                      (top)
                                                                                                      ())
                                                                                                   (cons
                                                                                                     tmp268
                                                                                                     '#(syntax-object
                                                                                                        ()
                                                                                                        (top)
                                                                                                        ()))))
                                                                                               x267)))
                                                                                      tmp266)
                                                                                    ((lambda (tmp269)
                                                                                       (if tmp269
                                                                                           (apply
                                                                                             (lambda (x270)
                                                                                               (k263
                                                                                                 x270))
                                                                                             tmp269)
                                                                                           ((lambda (tmp272)
                                                                                              (if tmp272
                                                                                                  (apply
                                                                                                    (lambda (x274
                                                                                                             y273)
                                                                                                      (f262
                                                                                                        y273
                                                                                                        (lambda (ls275)
                                                                                                          (k263
                                                                                                            (cons
                                                                                                              x274
                                                                                                              ls275)))))
                                                                                                    tmp272)
                                                                                                  (cons
                                                                                                    '#(syntax-object
                                                                                                       list->vector
                                                                                                       (top)
                                                                                                       ())
                                                                                                    (cons
                                                                                                      pat-x256
                                                                                                      '#(syntax-object
                                                                                                         ()
                                                                                                         (top)
                                                                                                         ())))))
                                                                                             ($syntax-dispatch
                                                                                               tmp265
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
                                                                                                          add-subst
                                                                                                          top-subst*
                                                                                                          same-marks?
                                                                                                          add-mark
                                                                                                          anti-mark
                                                                                                          the-anti-mark
                                                                                                          gen-mark
                                                                                                          top-marked?
                                                                                                          top-mark*
                                                                                                          unannotate
                                                                                                          syn->src
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
                                                                                                          "i")))))
                                                                                                  any
                                                                                                  any)))))
                                                                                      ($syntax-dispatch
                                                                                        tmp265
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
                                                                                                   add-subst
                                                                                                   top-subst*
                                                                                                   same-marks?
                                                                                                   add-mark
                                                                                                   anti-mark
                                                                                                   the-anti-mark
                                                                                                   gen-mark
                                                                                                   top-marked?
                                                                                                   top-mark*
                                                                                                   unannotate
                                                                                                   syn->src
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
                                                                                                   "i")))))
                                                                                           .
                                                                                           each-any)))))
                                                                               ($syntax-dispatch
                                                                                 tmp265
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
                                                                                            add-subst
                                                                                            top-subst*
                                                                                            same-marks?
                                                                                            add-mark
                                                                                            anti-mark
                                                                                            the-anti-mark
                                                                                            gen-mark
                                                                                            top-marked?
                                                                                            top-mark*
                                                                                            unannotate
                                                                                            syn->src
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
                                                                                            "i")))))
                                                                                    each-any))))
                                                                            x264))])
                                                           f262)
                                                          x254
                                                          (lambda (ls261)
                                                            (cons
                                                              '#(syntax-object
                                                                 vector
                                                                 (top) ())
                                                              (append
                                                                ls261
                                                                '()))))))
                                                   ($syntax-dispatch
                                                     tmp257
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
                                                                add-subst
                                                                top-subst*
                                                                same-marks?
                                                                add-mark
                                                                anti-mark
                                                                the-anti-mark
                                                                gen-mark
                                                                top-marked?
                                                                top-mark*
                                                                unannotate
                                                                syn->src
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
                                                                (top)
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
                                                                "i"
                                                                "i")))))
                                                        each-any))))
                                                pat-x256))
                                             tmp255))
                                          x254))]
                      [vquasi207 (lambda (p238 lev237)
                                   ((lambda (tmp239)
                                      ((lambda (tmp240)
                                         (if tmp240
                                             (apply
                                               (lambda (p242 q241)
                                                 ((lambda (tmp243)
                                                    ((lambda (tmp244)
                                                       (if tmp244
                                                           (apply
                                                             (lambda (p245)
                                                               (if (= lev237
                                                                      '0)
                                                                   (quasilist*203
                                                                     p245
                                                                     (vquasi207
                                                                       q241
                                                                       lev237))
                                                                   (quasicons204
                                                                     (quasicons204
                                                                       '#(syntax-object
                                                                          'unquote
                                                                          (top)
                                                                          ())
                                                                       (quasi208
                                                                         p245
                                                                         (- lev237
                                                                            '1)))
                                                                     (vquasi207
                                                                       q241
                                                                       lev237))))
                                                             tmp244)
                                                           ((lambda (tmp248)
                                                              (if tmp248
                                                                  (apply
                                                                    (lambda (p249)
                                                                      (if (= lev237
                                                                             '0)
                                                                          (quasiappend205
                                                                            p249
                                                                            (vquasi207
                                                                              q241
                                                                              lev237))
                                                                          (quasicons204
                                                                            (quasicons204
                                                                              '#(syntax-object
                                                                                 'unquote-splicing
                                                                                 (top)
                                                                                 ())
                                                                              (quasi208
                                                                                p249
                                                                                (- lev237
                                                                                   '1)))
                                                                            (vquasi207
                                                                              q241
                                                                              lev237))))
                                                                    tmp248)
                                                                  ((lambda (p252)
                                                                     (quasicons204
                                                                       (quasi208
                                                                         p252
                                                                         lev237)
                                                                       (vquasi207
                                                                         q241
                                                                         lev237)))
                                                                    tmp243)))
                                                             ($syntax-dispatch
                                                               tmp243
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
                                                                          add-subst
                                                                          top-subst*
                                                                          same-marks?
                                                                          add-mark
                                                                          anti-mark
                                                                          the-anti-mark
                                                                          gen-mark
                                                                          top-marked?
                                                                          top-mark*
                                                                          unannotate
                                                                          syn->src
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
                                                                          "i")))))
                                                                  .
                                                                  each-any)))))
                                                      ($syntax-dispatch
                                                        tmp243
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
                                                                   add-subst
                                                                   top-subst*
                                                                   same-marks?
                                                                   add-mark
                                                                   anti-mark
                                                                   the-anti-mark
                                                                   gen-mark
                                                                   top-marked?
                                                                   top-mark*
                                                                   unannotate
                                                                   syn->src
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
                                                                   "i"
                                                                   "i")))))
                                                           .
                                                           each-any))))
                                                   p242))
                                               tmp240)
                                             ((lambda (tmp253)
                                                (if tmp253
                                                    (apply
                                                      (lambda ()
                                                        '#(syntax-object
                                                           '() (top) ()))
                                                      tmp253)
                                                    (syntax-error tmp239)))
                                               ($syntax-dispatch
                                                 tmp239
                                                 '()))))
                                        ($syntax-dispatch
                                          tmp239
                                          '(any . any))))
                                     p238))]
                      [quasi208 (lambda (p214 lev213)
                                  ((lambda (tmp215)
                                     ((lambda (tmp216)
                                        (if tmp216
                                            (apply
                                              (lambda (p217)
                                                (if (= lev213 '0)
                                                    p217
                                                    (quasicons204
                                                      '#(syntax-object
                                                         'unquote (top) ())
                                                      (quasi208
                                                        (cons
                                                          p217
                                                          '#(syntax-object
                                                             () (top) ()))
                                                        (- lev213 '1)))))
                                              tmp216)
                                            ((lambda (tmp218)
                                               (if tmp218
                                                   (apply
                                                     (lambda (p220 q219)
                                                       (if (= lev213 '0)
                                                           (quasilist*203
                                                             p220
                                                             (quasi208
                                                               q219
                                                               lev213))
                                                           (quasicons204
                                                             (quasicons204
                                                               '#(syntax-object
                                                                  'unquote
                                                                  (top) ())
                                                               (quasi208
                                                                 p220
                                                                 (- lev213
                                                                    '1)))
                                                             (quasi208
                                                               q219
                                                               lev213))))
                                                     tmp218)
                                                   ((lambda (tmp223)
                                                      (if tmp223
                                                          (apply
                                                            (lambda (p225
                                                                     q224)
                                                              (if (= lev213
                                                                     '0)
                                                                  (quasiappend205
                                                                    p225
                                                                    (quasi208
                                                                      q224
                                                                      lev213))
                                                                  (quasicons204
                                                                    (quasicons204
                                                                      '#(syntax-object
                                                                         'unquote-splicing
                                                                         (top)
                                                                         ())
                                                                      (quasi208
                                                                        p225
                                                                        (- lev213
                                                                           '1)))
                                                                    (quasi208
                                                                      q224
                                                                      lev213))))
                                                            tmp223)
                                                          ((lambda (tmp228)
                                                             (if tmp228
                                                                 (apply
                                                                   (lambda (p229)
                                                                     (quasicons204
                                                                       '#(syntax-object
                                                                          'quasiquote
                                                                          (top)
                                                                          ())
                                                                       (quasi208
                                                                         (cons
                                                                           p229
                                                                           '#(syntax-object
                                                                              ()
                                                                              (top)
                                                                              ()))
                                                                         (+ lev213
                                                                            '1))))
                                                                   tmp228)
                                                                 ((lambda (tmp230)
                                                                    (if tmp230
                                                                        (apply
                                                                          (lambda (p232
                                                                                   q231)
                                                                            (quasicons204
                                                                              (quasi208
                                                                                p232
                                                                                lev213)
                                                                              (quasi208
                                                                                q231
                                                                                lev213)))
                                                                          tmp230)
                                                                        ((lambda (tmp233)
                                                                           (if tmp233
                                                                               (apply
                                                                                 (lambda (x234)
                                                                                   (quasivector206
                                                                                     (vquasi207
                                                                                       x234
                                                                                       lev213)))
                                                                                 tmp233)
                                                                               ((lambda (p236)
                                                                                  (cons
                                                                                    '#(syntax-object
                                                                                       quote
                                                                                       (top)
                                                                                       ())
                                                                                    (cons
                                                                                      p236
                                                                                      '#(syntax-object
                                                                                         ()
                                                                                         (top)
                                                                                         ()))))
                                                                                 tmp215)))
                                                                          ($syntax-dispatch
                                                                            tmp215
                                                                            '#(vector
                                                                               each-any)))))
                                                                   ($syntax-dispatch
                                                                     tmp215
                                                                     '(any .
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp215
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
                                                                         add-subst
                                                                         top-subst*
                                                                         same-marks?
                                                                         add-mark
                                                                         anti-mark
                                                                         the-anti-mark
                                                                         gen-mark
                                                                         top-marked?
                                                                         top-mark*
                                                                         unannotate
                                                                         syn->src
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
                                                                         "i")))))
                                                                 any)))))
                                                     ($syntax-dispatch
                                                       tmp215
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
                                                                   add-subst
                                                                   top-subst*
                                                                   same-marks?
                                                                   add-mark
                                                                   anti-mark
                                                                   the-anti-mark
                                                                   gen-mark
                                                                   top-marked?
                                                                   top-mark*
                                                                   unannotate
                                                                   syn->src
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
                                                                   "i"
                                                                   "i")))))
                                                           .
                                                           each-any)
                                                          .
                                                          any)))))
                                              ($syntax-dispatch
                                                tmp215
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
                                                            add-subst
                                                            top-subst*
                                                            same-marks?
                                                            add-mark
                                                            anti-mark
                                                            the-anti-mark
                                                            gen-mark
                                                            top-marked?
                                                            top-mark*
                                                            unannotate
                                                            syn->src strip
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
                                                            (top) (top))
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
                                                            "i" "i" "i"
                                                            "i")))))
                                                    .
                                                    each-any)
                                                   .
                                                   any)))))
                                       ($syntax-dispatch
                                         tmp215
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
                                                    add-subst top-subst*
                                                    same-marks? add-mark
                                                    anti-mark the-anti-mark
                                                    gen-mark top-marked?
                                                    top-mark* unannotate
                                                    syn->src strip
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
                                                    (top) (top) (top)
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
                                                    "i" "i")))))
                                            any))))
                                    p214))])
              (lambda (x209)
                ((lambda (tmp210)
                   ((lambda (tmp211)
                      (if tmp211
                          (apply (lambda (e212) (quasi208 e212 '0)) tmp211)
                          (syntax-error tmp210)))
                     ($syntax-dispatch tmp210 '(_ any))))
                  x209))))))
       (global-extend9
         'macro
         'unquote
         (lambda (x199)
           ((lambda (tmp200)
              ((lambda (tmp201)
                 (if tmp201
                     (apply
                       (lambda (e202)
                         (syntax-error
                           x199
                           '"expression not valid outside of quasiquote"))
                       tmp201)
                     (syntax-error tmp200)))
                ($syntax-dispatch tmp200 '(_ . each-any))))
             x199)))
       (global-extend9
         'macro
         'unquote-splicing
         (lambda (x195)
           ((lambda (tmp196)
              ((lambda (tmp197)
                 (if tmp197
                     (apply
                       (lambda (e198)
                         (syntax-error
                           x195
                           '"expression not valid outside of quasiquote"))
                       tmp197)
                     (syntax-error tmp196)))
                ($syntax-dispatch tmp196 '(_ . each-any))))
             x195)))
       (global-extend9
         'macro
         'case
         (lambda (x163)
           ((lambda (tmp164)
              ((lambda (tmp165)
                 (if tmp165
                     (apply
                       (lambda (dummy172 e0171 k170 e1169 e2168 else-e1167
                                else-e2166)
                         (cons
                           '#(syntax-object let (top) ())
                           (cons
                             (cons
                               (cons
                                 '#(syntax-object t (top) ())
                                 (cons
                                   e0171
                                   '#(syntax-object () (top) ())))
                               '#(syntax-object () (top) ()))
                             (cons
                               (cons
                                 '#(syntax-object cond (top) ())
                                 (append
                                   (map (lambda (tmp177 tmp176 tmp174)
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
                                                      tmp174
                                                      '#(syntax-object ()
                                                         (top) ())))
                                                  '#(syntax-object () (top)
                                                     ()))))
                                            (cons tmp176 tmp177)))
                                        e2168
                                        e1169
                                        k170)
                                   (cons
                                     (cons
                                       '#(syntax-object else (top) ())
                                       (cons else-e1167 else-e2166))
                                     '#(syntax-object () (top) ()))))
                               '#(syntax-object () (top) ())))))
                       tmp165)
                     ((lambda (tmp179)
                        (if tmp179
                            (apply
                              (lambda (dummy187 e0186 ka185 e1a184 e2a183
                                       kb182 e1b181 e2b180)
                                (cons
                                  '#(syntax-object let (top) ())
                                  (cons
                                    (cons
                                      (cons
                                        '#(syntax-object t (top) ())
                                        (cons
                                          e0186
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
                                                      ka185
                                                      '#(syntax-object ()
                                                         (top) ())))
                                                  '#(syntax-object () (top)
                                                     ()))))
                                            (cons e1a184 e2a183))
                                          (map (lambda (tmp193 tmp192
                                                        tmp190)
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
                                                             tmp190
                                                             '#(syntax-object
                                                                () (top)
                                                                ())))
                                                         '#(syntax-object
                                                            () (top) ()))))
                                                   (cons tmp192 tmp193)))
                                               e2b180
                                               e1b181
                                               kb182)))
                                      '#(syntax-object () (top) ())))))
                              tmp179)
                            (syntax-error tmp164)))
                       ($syntax-dispatch
                         tmp164
                         '(any any
                               (each-any any . each-any)
                               .
                               #(each (each-any any . each-any)))))))
                ($syntax-dispatch
                  tmp164
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
                                     rib-sym* rib? make-rib add-subst
                                     top-subst* same-marks? add-mark
                                     anti-mark the-anti-mark gen-mark
                                     top-marked? top-mark* unannotate
                                     syn->src strip
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
                                     (top) (top))
                                    ("i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i")))))
                             any
                             .
                             each-any))
                          ())))))
             x163)))
       (global-extend9
         'macro
         'identifier-syntax
         (lambda (x145)
           ((lambda (tmp146)
              ((lambda (tmp147)
                 (if tmp147
                     (apply
                       (lambda (dummy149 e148)
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
                                                 e148
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
                                                   e148
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
                       tmp147)
                     ((lambda (tmp150)
                        (if (if tmp150
                                (apply
                                  (lambda (dummy156 id155 exp1154 var153
                                           rhs152 exp2151)
                                    (if (identifier? id155)
                                        (identifier? var153)
                                        '#f))
                                  tmp150)
                                '#f)
                            (apply
                              (lambda (dummy162 id161 exp1160 var159 rhs158
                                       exp2157)
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
                                                        var159
                                                        (cons
                                                          rhs158
                                                          '#(syntax-object
                                                             () (top)
                                                             ()))))
                                                    (cons
                                                      (cons
                                                        '#(syntax-object
                                                           syntax (top) ())
                                                        (cons
                                                          exp2157
                                                          '#(syntax-object
                                                             () (top) ())))
                                                      '#(syntax-object ()
                                                         (top) ())))
                                                  (cons
                                                    (cons
                                                      (cons
                                                        id161
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
                                                              exp1160
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
                                                        id161
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
                                                                  id161
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
                                                                exp1160
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
                              tmp150)
                            (syntax-error tmp146)))
                       ($syntax-dispatch
                         tmp146
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
                                          add-subst top-subst* same-marks?
                                          add-mark anti-mark the-anti-mark
                                          gen-mark top-marked? top-mark*
                                          unannotate syn->src strip
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
                                          (top) (top) (top) (top) (top))
                                         ("i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i" "i"
                                          "i" "i" "i" "i" "i" "i" "i"
                                          "i")))))
                                  any
                                  any)
                                 any))))))
                ($syntax-dispatch tmp146 '(any any))))
             x145)))
       (global-extend9
         'macro
         'when
         (lambda (x137)
           ((lambda (tmp138)
              ((lambda (tmp139)
                 (if tmp139
                     (apply
                       (lambda (dummy143 test142 e1141 e2140)
                         (cons
                           '#(syntax-object if (top) ())
                           (cons
                             test142
                             (cons
                               (cons
                                 '#(syntax-object begin (top) ())
                                 (cons e1141 e2140))
                               '#(syntax-object () (top) ())))))
                       tmp139)
                     (syntax-error tmp138)))
                ($syntax-dispatch tmp138 '(any any any . each-any))))
             x137)))
       (global-extend9
         'macro
         'unless
         (lambda (x129)
           ((lambda (tmp130)
              ((lambda (tmp131)
                 (if tmp131
                     (apply
                       (lambda (dummy135 test134 e1133 e2132)
                         (cons
                           '#(syntax-object when (top) ())
                           (cons
                             (cons
                               '#(syntax-object not (top) ())
                               (cons
                                 test134
                                 '#(syntax-object () (top) ())))
                             (cons
                               (cons
                                 '#(syntax-object begin (top) ())
                                 (cons e1133 e2132))
                               '#(syntax-object () (top) ())))))
                       tmp131)
                     (syntax-error tmp130)))
                ($syntax-dispatch tmp130 '(any any any . each-any))))
             x129)))))))
