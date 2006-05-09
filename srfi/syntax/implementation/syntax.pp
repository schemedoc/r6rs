;;; syntax.pp
;;; automatically generated from syntax.ss
;;; Tue May  9 14:40:32 2006
;;; see copyright notice in syntax.ss

((lambda ()
   (letrec* ([eval-hook0 eval]
             [error-hook1 (lambda (who1251 why1250 what1249)
                            (error who1251 '"~a ~s" why1250 what1249))]
             [gensym-hook2 gensym]
             [no-source3 '#f]
             [annotation?4 (lambda (x1248) '#f)]
             [annotation-expression5 (lambda (x1247) x1247)]
             [annotation-source6 (lambda (x1246) no-source3)]
             [strip-annotation7 (lambda (x1245) x1245)]
             [globals8 '()]
             [global-extend9 (lambda (type1244 sym1243 value1242)
                               (set! globals8
                                 (cons
                                   (cons
                                     sym1243
                                     (make-binding126 type1244 value1242))
                                   globals8)))]
             [global-lookup10 (lambda (sym1240)
                                ((lambda (t1241)
                                   (if t1241
                                       (cdr t1241)
                                       (cons 'global sym1240)))
                                  (assq sym1240 globals8)))]
             [build-application11 (lambda (src1239 proc-expr1238
                                           arg-expr*1237)
                                    (cons proc-expr1238 arg-expr*1237))]
             [build-global-reference25 (lambda (src1236 var1235)
                                         var1235)]
             [build-lexical-reference26 (lambda (src1234 var1233)
                                          var1233)]
             [build-lexical-assignment27 (lambda (src1232 var1231
                                                  expr1230)
                                           (cons
                                             'set!
                                             (cons
                                               var1231
                                               (cons expr1230 '()))))]
             [build-global-assignment28 (lambda (src1229 var1228
                                                 expr1227)
                                          (cons
                                            'set!
                                            (cons
                                              var1228
                                              (cons expr1227 '()))))]
             [build-lambda29 (lambda (src1223 var*1222 rest?1221
                                      expr1220)
                               (cons
                                 'lambda
                                 (cons
                                   (if rest?1221
                                       ((letrec ([f1224 (lambda (var1226
                                                                 var*1225)
                                                          (if (pair?
                                                                var*1225)
                                                              (cons
                                                                var1226
                                                                (f1224
                                                                  (car var*1225)
                                                                  (cdr var*1225)))
                                                              var1226))])
                                          f1224)
                                         (car var*1222)
                                         (cdr var*1222))
                                       var*1222)
                                   (cons expr1220 '()))))]
             [build-primref30 (lambda (src1219 name1218) name1218)]
             [build-data31 (lambda (src1217 datum1216)
                             (cons 'quote (cons datum1216 '())))]
             [build-sequence32 (lambda (src1213 expr*1212)
                                 ((letrec ([loop1214 (lambda (expr*1215)
                                                       (if (null?
                                                             (cdr expr*1215))
                                                           (car expr*1215)
                                                           (cons
                                                             'begin
                                                             (append
                                                               expr*1215
                                                               '()))))])
                                    loop1214)
                                   expr*1212))]
             [build-letrec33 (lambda (src1211 var*1210 rhs-expr*1209
                                      body-expr1208)
                               (if (null? var*1210)
                                   body-expr1208
                                   (cons
                                     'letrec
                                     (cons
                                       (map list var*1210 rhs-expr*1209)
                                       (cons body-expr1208 '())))))]
             [build-letrec*34 (lambda (src1207 var*1206 rhs-expr*1205
                                       body-expr1204)
                                (if (null? var*1206)
                                    body-expr1204
                                    (cons
                                      'letrec*
                                      (cons
                                        (map list var*1206 rhs-expr*1205)
                                        (cons body-expr1204 '())))))]
             [build-lexical-var35 (lambda (src1203 id1202) (gensym))]
             [self-evaluating?36 (lambda (x1198)
                                   ((lambda (t1199)
                                      (if t1199
                                          t1199
                                          ((lambda (t1200)
                                             (if t1200
                                                 t1200
                                                 ((lambda (t1201)
                                                    (if t1201
                                                        t1201
                                                        (char? x1198)))
                                                   (string? x1198))))
                                            (number? x1198))))
                                     (boolean? x1198)))]
             [andmap37 (lambda (f1192 ls1191 . more1190)
                         ((letrec ([andmap1193 (lambda (ls1196 more1195
                                                        a1194)
                                                 (if (null? ls1196)
                                                     a1194
                                                     ((lambda (a1197)
                                                        (if a1197
                                                            (andmap1193
                                                              (cdr ls1196)
                                                              (map cdr
                                                                   more1195)
                                                              a1197)
                                                            '#f))
                                                       (apply
                                                         f1192
                                                         (car ls1196)
                                                         (map car
                                                              more1195)))))])
                            andmap1193)
                           ls1191
                           more1190
                           '#t))]
             [syntax-error93 (lambda (object1187 . messages1186)
                               (begin
                                 (for-each
                                   (lambda (x1189)
                                     (arg-check
                                       string?
                                       x1189
                                       'syntax-error))
                                   messages1186)
                                 ((lambda (message1188)
                                    (error-hook1
                                      '#f
                                      message1188
                                      (strip102 object1187 '())))
                                   (if (null? messages1186)
                                       '"invalid syntax"
                                       (apply
                                         string-append
                                         messages1186)))))]
             [make-syntax-object94 (lambda (expression1185 mark*1184
                                            subst*1183)
                                     (vector
                                       'syntax-object
                                       expression1185
                                       mark*1184
                                       subst*1183))]
             [syntax-object?95 (lambda (x1182)
                                 (if (vector? x1182)
                                     (if (= (vector-length x1182) '4)
                                         (eq? (vector-ref x1182 '0)
                                              'syntax-object)
                                         '#f)
                                     '#f))]
             [syntax-object-expression96 (lambda (x1181)
                                           (vector-ref x1181 '1))]
             [syntax-object-mark*97 (lambda (x1180)
                                      (vector-ref x1180 '2))]
             [syntax-object-subst*98 (lambda (x1179)
                                       (vector-ref x1179 '3))]
             [set-syntax-object-expression!99 (lambda (x1178 update1177)
                                                (vector-set!
                                                  x1178
                                                  '1
                                                  update1177))]
             [set-syntax-object-mark*!100 (lambda (x1176 update1175)
                                            (vector-set!
                                              x1176
                                              '2
                                              update1175))]
             [set-syntax-object-subst*!101 (lambda (x1174 update1173)
                                             (vector-set!
                                               x1174
                                               '3
                                               update1173))]
             [strip102 (lambda (x1166 m*1165)
                         (if (top-marked?106 m*1165)
                             (strip-annotation7 x1166)
                             ((letrec ([f1167 (lambda (x1168)
                                                (if (syntax-object?95
                                                      x1168)
                                                    (strip102
                                                      (syntax-object-expression96
                                                        x1168)
                                                      (syntax-object-mark*97
                                                        x1168))
                                                    (if (pair? x1168)
                                                        ((lambda (a1170
                                                                  d1169)
                                                           (if (if (eq? a1170
                                                                        (car x1168))
                                                                   (eq? d1169
                                                                        (cdr x1168))
                                                                   '#f)
                                                               x1168
                                                               (cons
                                                                 a1170
                                                                 d1169)))
                                                          (f1167
                                                            (car x1168))
                                                          (f1167
                                                            (cdr x1168)))
                                                        (if (vector? x1168)
                                                            ((lambda (old1171)
                                                               ((lambda (new1172)
                                                                  (if (andmap37
                                                                        eq?
                                                                        old1171
                                                                        new1172)
                                                                      x1168
                                                                      (list->vector
                                                                        new1172)))
                                                                 (map f1167
                                                                      old1171)))
                                                              (vector->list
                                                                x1168))
                                                            x1168))))])
                                f1167)
                               x1166)))]
             [syn->src103 (lambda (e1163)
                            ((lambda (x1164)
                               (if (annotation?4 x1164)
                                   (annotation-source6 x1164)
                                   no-source3))
                              (syntax-object-expression96 e1163)))]
             [unannotate104 (lambda (x1162)
                              (if (annotation?4 x1162)
                                  (annotation-expression5 x1162)
                                  x1162))]
             [top-mark*105 '(top)]
             [top-marked?106 (lambda (m*1161)
                               (memq (car top-mark*105) m*1161))]
             [gen-mark107 (lambda () (string '#\m))]
             [the-anti-mark108 '#f]
             [anti-mark109 (lambda (e1160)
                             (make-syntax-object94
                               (syntax-object-expression96 e1160)
                               (cons
                                 the-anti-mark108
                                 (syntax-object-mark*97 e1160))
                               (cons
                                 'shift
                                 (syntax-object-subst*98 e1160))))]
             [add-mark110 (lambda (m1158 e1157)
                            ((lambda (mark*1159)
                               (if (if (pair? mark*1159)
                                       (eq? (car mark*1159)
                                            the-anti-mark108)
                                       '#f)
                                   (make-syntax-object94
                                     (syntax-object-expression96 e1157)
                                     (cdr mark*1159)
                                     (cdr (syntax-object-subst*98 e1157)))
                                   (make-syntax-object94
                                     (syntax-object-expression96 e1157)
                                     (cons m1158 mark*1159)
                                     (cons
                                       'shift
                                       (syntax-object-subst*98 e1157)))))
                              (syntax-object-mark*97 e1157)))]
             [same-marks?111 (lambda (x1155 y1154)
                               ((lambda (t1156)
                                  (if t1156
                                      t1156
                                      (if (if (not (null? x1155))
                                              (not (null? y1154))
                                              '#f)
                                          (if (eq? (car x1155) (car y1154))
                                              (same-marks?111
                                                (cdr x1155)
                                                (cdr y1154))
                                              '#f)
                                          '#f)))
                                 (eq? x1155 y1154)))]
             [top-subst*112 '()]
             [add-subst113 (lambda (subst1153 e1152)
                             (if subst1153
                                 (make-syntax-object94
                                   (syntax-object-expression96 e1152)
                                   (syntax-object-mark*97 e1152)
                                   (cons
                                     subst1153
                                     (syntax-object-subst*98 e1152)))
                                 e1152))]
             [make-rib114 (lambda (sym*1151 mark**1150 label*1149)
                            (vector 'rib sym*1151 mark**1150 label*1149))]
             [rib?115 (lambda (x1148)
                        (if (vector? x1148)
                            (if (= (vector-length x1148) '4)
                                (eq? (vector-ref x1148 '0) 'rib)
                                '#f)
                            '#f))]
             [rib-sym*116 (lambda (x1147) (vector-ref x1147 '1))]
             [rib-mark**117 (lambda (x1146) (vector-ref x1146 '2))]
             [rib-label*118 (lambda (x1145) (vector-ref x1145 '3))]
             [set-rib-sym*!119 (lambda (x1144 update1143)
                                 (vector-set! x1144 '1 update1143))]
             [set-rib-mark**!120 (lambda (x1142 update1141)
                                   (vector-set! x1142 '2 update1141))]
             [set-rib-label*!121 (lambda (x1140 update1139)
                                   (vector-set! x1140 '3 update1139))]
             [make-empty-rib122 (lambda () (make-rib114 '() '() '()))]
             [extend-rib!123 (lambda (rib1138 id1137 label1136)
                               (begin
                                 (set-rib-sym*!119
                                   rib1138
                                   (cons
                                     (id->sym136 id1137)
                                     (rib-sym*116 rib1138)))
                                 (set-rib-mark**!120
                                   rib1138
                                   (cons
                                     (syntax-object-mark*97 id1137)
                                     (rib-mark**117 rib1138)))
                                 (set-rib-label*!121
                                   rib1138
                                   (cons
                                     label1136
                                     (rib-label*118 rib1138)))))]
             [make-full-rib124 (lambda (id*1129 label*1128)
                                 (if (not (null? id*1129))
                                     (call-with-values
                                       (lambda ()
                                         ((letrec ([f1132 (lambda (id*1133)
                                                            (if (null?
                                                                  id*1133)
                                                                (values
                                                                  '()
                                                                  '())
                                                                (call-with-values
                                                                  (lambda ()
                                                                    (f1132
                                                                      (cdr id*1133)))
                                                                  (lambda (sym*1135
                                                                           mark**1134)
                                                                    (values
                                                                      (cons
                                                                        (id->sym136
                                                                          (car id*1133))
                                                                        sym*1135)
                                                                      (cons
                                                                        (syntax-object-mark*97
                                                                          (car id*1133))
                                                                        mark**1134))))))])
                                            f1132)
                                           id*1129))
                                       (lambda (sym*1131 mark**1130)
                                         (make-rib114
                                           sym*1131
                                           mark**1130
                                           label*1128)))
                                     '#f))]
             [gen-label125 (lambda () (string '#\i))]
             [make-binding126 cons]
             [binding-type127 car]
             [binding-value128 cdr]
             [null-env129 '()]
             [extend-env130 (lambda (label1127 binding1126 r1125)
                              (cons (cons label1127 binding1126) r1125))]
             [extend-env*131 (lambda (label*1124 binding*1123 r1122)
                               (if (null? label*1124)
                                   r1122
                                   (extend-env*131
                                     (cdr label*1124)
                                     (cdr binding*1123)
                                     (extend-env130
                                       (car label*1124)
                                       (car binding*1123)
                                       r1122))))]
             [extend-var-env*132 (lambda (label*1121 var*1120 r1119)
                                   (if (null? label*1121)
                                       r1119
                                       (extend-var-env*132
                                         (cdr label*1121)
                                         (cdr var*1120)
                                         (extend-env130
                                           (car label*1121)
                                           (make-binding126
                                             'lexical
                                             (car var*1120))
                                           r1119))))]
             [displaced-lexical-error133 (lambda (id1118)
                                           (syntax-error93
                                             id1118
                                             '"identifier out of context"))]
             [eval-transformer134 (lambda (x1116)
                                    ((lambda (x1117)
                                       (if (procedure? x1117)
                                           (make-binding126 'macro x1117)
                                           (if (if (pair? x1117)
                                                   (if (eq? (car x1117)
                                                            'macro!)
                                                       (procedure?
                                                         (cdr x1117))
                                                       '#f)
                                                   '#f)
                                               x1117
                                               (syntax-error93
                                                 b
                                                 '"invalid transformer"))))
                                      (eval-hook0 x1116)))]
             [id?135 (lambda (x1115)
                       (if (syntax-object?95 x1115)
                           (symbol?
                             (unannotate104
                               (syntax-object-expression96 x1115)))
                           '#f))]
             [id->sym136 (lambda (x1114)
                           (unannotate104
                             (syntax-object-expression96 x1114)))]
             [gen-var137 (lambda (id1113)
                           (build-lexical-var35
                             (syn->src103 id1113)
                             (id->sym136 id1113)))]
             [id->label138 (lambda (id1104)
                             ((lambda (sym1105)
                                ((letrec ([search1106 (lambda (subst*1108
                                                               mark*1107)
                                                        (if (null?
                                                              subst*1108)
                                                            sym1105
                                                            ((lambda (subst1109)
                                                               (if (eq? subst1109
                                                                        'shift)
                                                                   (search1106
                                                                     (cdr subst*1108)
                                                                     (cdr mark*1107))
                                                                   ((letrec ([search-rib1110 (lambda (sym*1112
                                                                                                      i1111)
                                                                                               (if (null?
                                                                                                     sym*1112)
                                                                                                   (search1106
                                                                                                     (cdr subst*1108)
                                                                                                     mark*1107)
                                                                                                   (if (if (eq? (car sym*1112)
                                                                                                                sym1105)
                                                                                                           (same-marks?111
                                                                                                             mark*1107
                                                                                                             (list-ref
                                                                                                               (rib-mark**117
                                                                                                                 subst1109)
                                                                                                               i1111))
                                                                                                           '#f)
                                                                                                       (list-ref
                                                                                                         (rib-label*118
                                                                                                           subst1109)
                                                                                                         i1111)
                                                                                                       (search-rib1110
                                                                                                         (cdr sym*1112)
                                                                                                         (+ i1111
                                                                                                            '1)))))])
                                                                      search-rib1110)
                                                                     (rib-sym*116
                                                                       subst1109)
                                                                     '0)))
                                                              (car subst*1108))))])
                                   search1106)
                                  (syntax-object-subst*98 id1104)
                                  (syntax-object-mark*97 id1104)))
                               (id->sym136 id1104)))]
             [label->binding139 (lambda (x1102 r1101)
                                  (if (symbol? x1102)
                                      (global-lookup10 x1102)
                                      ((lambda (t1103)
                                         (if t1103
                                             (cdr t1103)
                                             (make-binding126
                                               'displaced-lexical
                                               '#f)))
                                        (assq x1102 r1101))))]
             [free-id=?140 (lambda (i1100 j1099)
                             (eq? (id->label138 i1100)
                                  (id->label138 j1099)))]
             [bound-id=?141 (lambda (i1098 j1097)
                              (if (eq? (id->sym136 i1098)
                                       (id->sym136 j1097))
                                  (same-marks?111
                                    (syntax-object-mark*97 i1098)
                                    (syntax-object-mark*97 j1097))
                                  '#f))]
             [bound-id-member?142 (lambda (x1095 list1094)
                                    (if (not (null? list1094))
                                        ((lambda (t1096)
                                           (if t1096
                                               t1096
                                               (bound-id-member?142
                                                 x1095
                                                 (cdr list1094))))
                                          (bound-id=?141
                                            x1095
                                            (car list1094)))
                                        '#f))]
             [valid-bound-ids?143 (lambda (id*1090)
                                    (if ((letrec ([all-ids?1091 (lambda (id*1092)
                                                                  ((lambda (t1093)
                                                                     (if t1093
                                                                         t1093
                                                                         (if (id?135
                                                                               (car id*1092))
                                                                             (all-ids?1091
                                                                               (cdr id*1092))
                                                                             '#f)))
                                                                    (null?
                                                                      id*1092)))])
                                           all-ids?1091)
                                          id*1090)
                                        (distinct-bound-ids?144 id*1090)
                                        '#f))]
             [distinct-bound-ids?144 (lambda (id*1086)
                                       ((letrec ([distinct?1087 (lambda (id*1088)
                                                                  ((lambda (t1089)
                                                                     (if t1089
                                                                         t1089
                                                                         (if (not (bound-id-member?142
                                                                                    (car id*1088)
                                                                                    (cdr id*1088)))
                                                                             (distinct?1087
                                                                               (cdr id*1088))
                                                                             '#f)))
                                                                    (null?
                                                                      id*1088)))])
                                          distinct?1087)
                                         id*1086))]
             [invalid-ids-error145 (lambda (id*1082 e1081 class1080)
                                     ((letrec ([find1083 (lambda (id*1085
                                                                  ok*1084)
                                                           (if (null?
                                                                 id*1085)
                                                               (syntax-error93
                                                                 e1081)
                                                               (if (id?135
                                                                     (car id*1085))
                                                                   (if (bound-id-member?142
                                                                         (car id*1085)
                                                                         ok*1084)
                                                                       (syntax-error93
                                                                         (car id*1085)
                                                                         '"duplicate "
                                                                         class1080)
                                                                       (find1083
                                                                         (cdr id*1085)
                                                                         (cons
                                                                           (car id*1085)
                                                                           ok*1084)))
                                                                   (syntax-error93
                                                                     (car id*1085)
                                                                     '"invalid "
                                                                     class1080))))])
                                        find1083)
                                       id*1082
                                       '()))])
     (begin
       ((lambda ()
          (letrec* ([syntax-type609 (lambda (e1063 r1062)
                                      ((lambda (tmp1064)
                                         ((lambda (tmp1065)
                                            (if (if tmp1065
                                                    (apply
                                                      (lambda (id1066)
                                                        (id?135 id1066))
                                                      tmp1065)
                                                    '#f)
                                                (apply
                                                  (lambda (id1067)
                                                    ((lambda (label1068)
                                                       ((lambda (b1069)
                                                          ((lambda (type1070)
                                                             ((lambda (t1071)
                                                                (if (memv
                                                                      t1071
                                                                      '(macro
                                                                         macro!
                                                                         lexical
                                                                         global
                                                                         syntax
                                                                         displaced-lexical))
                                                                    (values
                                                                      type1070
                                                                      (binding-value128
                                                                        b1069))
                                                                    (values
                                                                      'other
                                                                      '#f)))
                                                               type1070))
                                                            (binding-type127
                                                              b1069)))
                                                         (label->binding139
                                                           label1068
                                                           r1062)))
                                                      (id->label138
                                                        id1067)))
                                                  tmp1065)
                                                ((lambda (tmp1072)
                                                   (if tmp1072
                                                       (apply
                                                         (lambda (id1074
                                                                  rest1073)
                                                           (if (id?135
                                                                 id1074)
                                                               ((lambda (label1075)
                                                                  ((lambda (b1076)
                                                                     ((lambda (type1077)
                                                                        ((lambda (t1078)
                                                                           (if (memv
                                                                                 t1078
                                                                                 '(macro
                                                                                    macro!
                                                                                    core
                                                                                    begin
                                                                                    define
                                                                                    define-syntax
                                                                                    local-syntax))
                                                                               (values
                                                                                 type1077
                                                                                 (binding-value128
                                                                                   b1076))
                                                                               (values
                                                                                 'call
                                                                                 '#f)))
                                                                          type1077))
                                                                       (binding-type127
                                                                         b1076)))
                                                                    (label->binding139
                                                                      label1075
                                                                      r1062)))
                                                                 (id->label138
                                                                   id1074))
                                                               (values
                                                                 'call
                                                                 '#f)))
                                                         tmp1072)
                                                       ((lambda (d1079)
                                                          (if (self-evaluating?36
                                                                d1079)
                                                              (values
                                                                'constant
                                                                d1079)
                                                              (values
                                                                'other
                                                                '#f)))
                                                         (strip102
                                                           e1063
                                                           '()))))
                                                  ($syntax-dispatch
                                                    tmp1064
                                                    '(any . any)))))
                                           ($syntax-dispatch
                                             tmp1064
                                             'any)))
                                        e1063))]
                    [chi610 (lambda (e1055 r1054 mr1053)
                              (call-with-values
                                (lambda () (syntax-type609 e1055 r1054))
                                (lambda (type1057 value1056)
                                  ((lambda (t1058)
                                     (if (memv t1058 '(lexical))
                                         (build-lexical-reference26
                                           (syn->src103 e1055)
                                           value1056)
                                         (if (memv t1058 '(global))
                                             (build-global-reference25
                                               (syn->src103 e1055)
                                               value1056)
                                             (if (memv t1058 '(core))
                                                 (value1056
                                                   e1055
                                                   r1054
                                                   mr1053)
                                                 (if (memv
                                                       t1058
                                                       '(constant))
                                                     (build-data31
                                                       (syn->src103 e1055)
                                                       value1056)
                                                     (if (memv
                                                           t1058
                                                           '(call))
                                                         (chi-application612
                                                           e1055
                                                           r1054
                                                           mr1053)
                                                         (if (memv
                                                               t1058
                                                               '(begin))
                                                             (build-sequence32
                                                               (syn->src103
                                                                 e1055)
                                                               (chi-exprs611
                                                                 (parse-begin617
                                                                   e1055
                                                                   '#f)
                                                                 r1054
                                                                 mr1053))
                                                             (if (memv
                                                                   t1058
                                                                   '(macro
                                                                      macro!))
                                                                 (chi610
                                                                   (chi-macro613
                                                                     value1056
                                                                     e1055)
                                                                   r1054
                                                                   mr1053)
                                                                 (if (memv
                                                                       t1058
                                                                       '(local-syntax))
                                                                     (call-with-values
                                                                       (lambda ()
                                                                         (chi-local-syntax618
                                                                           value1056
                                                                           e1055
                                                                           r1054
                                                                           mr1053))
                                                                       (lambda (e*1061
                                                                                r1060
                                                                                mr1059)
                                                                         (build-sequence32
                                                                           (syn->src103
                                                                             e1055)
                                                                           (chi-exprs611
                                                                             e*1061
                                                                             r1060
                                                                             mr1059))))
                                                                     (if (memv
                                                                           t1058
                                                                           '(define))
                                                                         (begin
                                                                           (parse-define615
                                                                             e1055)
                                                                           (syntax-error93
                                                                             e1055
                                                                             '"invalid context for definition"))
                                                                         (if (memv
                                                                               t1058
                                                                               '(define-syntax))
                                                                             (begin
                                                                               (parse-define-syntax616
                                                                                 e1055)
                                                                               (syntax-error93
                                                                                 e1055
                                                                                 '"invalid context for definition"))
                                                                             (if (memv
                                                                                   t1058
                                                                                   '(syntax))
                                                                                 (syntax-error93
                                                                                   e1055
                                                                                   '"reference to pattern variable outside syntax form")
                                                                                 (if (memv
                                                                                       t1058
                                                                                       '(displaced-lexical))
                                                                                     (displaced-lexical-error133
                                                                                       e1055)
                                                                                     (syntax-error93
                                                                                       e1055))))))))))))))
                                    type1057))))]
                    [chi-exprs611 (lambda (x*1051 r1050 mr1049)
                                    (map (lambda (x1052)
                                           (chi610 x1052 r1050 mr1049))
                                         x*1051))]
                    [chi-application612 (lambda (e1043 r1042 mr1041)
                                          ((lambda (tmp1044)
                                             ((lambda (tmp1045)
                                                (if tmp1045
                                                    (apply
                                                      (lambda (e01047
                                                               e11046)
                                                        (build-application11
                                                          (syn->src103
                                                            e1043)
                                                          (chi610
                                                            e01047
                                                            r1042
                                                            mr1041)
                                                          (chi-exprs611
                                                            e11046
                                                            r1042
                                                            mr1041)))
                                                      tmp1045)
                                                    (syntax-error
                                                      tmp1044)))
                                               ($syntax-dispatch
                                                 tmp1044
                                                 '(any . each-any))))
                                            e1043))]
                    [chi-macro613 (lambda (p1038 orig-e1037)
                                    ((lambda (e1039)
                                       ((lambda (e1040)
                                          (add-mark110
                                            (gen-mark107)
                                            e1040))
                                         (if (syntax-object?95 e1039)
                                             e1039
                                             (make-syntax-object94
                                               e1039
                                               '()
                                               '()))))
                                      (p1038 (anti-mark109 orig-e1037))))]
                    [chi-body614 (lambda (outer-e1012 e*1011 r1010 mr1009)
                                   ((lambda (rib1013)
                                      ((letrec ([parse1015 (lambda (e*1021
                                                                    r1020
                                                                    mr1019
                                                                    id*1018
                                                                    var*1017
                                                                    rhs*1016)
                                                             (if (null?
                                                                   e*1021)
                                                                 (syntax-error93
                                                                   outer-e1012
                                                                   '"no expressions in body")
                                                                 ((lambda (e1022)
                                                                    (call-with-values
                                                                      (lambda ()
                                                                        (syntax-type609
                                                                          e1022
                                                                          r1020))
                                                                      (lambda (type1024
                                                                               value1023)
                                                                        ((lambda (t1025)
                                                                           (if (memv
                                                                                 t1025
                                                                                 '(define))
                                                                               (call-with-values
                                                                                 (lambda ()
                                                                                   (parse-define615
                                                                                     e1022))
                                                                                 (lambda (id1027
                                                                                          rhs1026)
                                                                                   ((lambda (label1029
                                                                                             var1028)
                                                                                      (begin
                                                                                        (extend-rib!123
                                                                                          rib1013
                                                                                          id1027
                                                                                          label1029)
                                                                                        (parse1015
                                                                                          (cdr e*1021)
                                                                                          (extend-env130
                                                                                            label1029
                                                                                            (make-binding126
                                                                                              'lexical
                                                                                              var1028)
                                                                                            r1020)
                                                                                          mr1019
                                                                                          (cons
                                                                                            id1027
                                                                                            id*1018)
                                                                                          (cons
                                                                                            var1028
                                                                                            var*1017)
                                                                                          (cons
                                                                                            rhs1026
                                                                                            rhs*1016))))
                                                                                     (gen-label125)
                                                                                     (gen-var137
                                                                                       id1027))))
                                                                               (if (memv
                                                                                     t1025
                                                                                     '(define-syntax))
                                                                                   (call-with-values
                                                                                     (lambda ()
                                                                                       (parse-define-syntax616
                                                                                         e1022))
                                                                                     (lambda (id1031
                                                                                              rhs1030)
                                                                                       ((lambda (label1032)
                                                                                          (begin
                                                                                            (extend-rib!123
                                                                                              rib1013
                                                                                              id1031
                                                                                              label1032)
                                                                                            ((lambda (b1033)
                                                                                               (parse1015
                                                                                                 (cdr e*1021)
                                                                                                 (extend-env130
                                                                                                   label1032
                                                                                                   b1033
                                                                                                   r1020)
                                                                                                 (extend-env130
                                                                                                   label1032
                                                                                                   b1033
                                                                                                   mr1019)
                                                                                                 (cons
                                                                                                   id1031
                                                                                                   id*1018)
                                                                                                 var*1017
                                                                                                 rhs*1016))
                                                                                              (eval-transformer134
                                                                                                (chi610
                                                                                                  rhs1030
                                                                                                  mr1019
                                                                                                  mr1019)))))
                                                                                         (gen-label125))))
                                                                                   (if (memv
                                                                                         t1025
                                                                                         '(begin))
                                                                                       (parse1015
                                                                                         (append
                                                                                           (parse-begin617
                                                                                             e1022
                                                                                             '#t)
                                                                                           (cdr e*1021))
                                                                                         r1020
                                                                                         mr1019
                                                                                         id*1018
                                                                                         var*1017
                                                                                         rhs*1016)
                                                                                       (if (memv
                                                                                             t1025
                                                                                             '(macro
                                                                                                macro!))
                                                                                           (parse1015
                                                                                             (cons
                                                                                               (add-subst113
                                                                                                 rib1013
                                                                                                 (chi-macro613
                                                                                                   value1023
                                                                                                   e1022))
                                                                                               (cdr e*1021))
                                                                                             r1020
                                                                                             mr1019
                                                                                             id*1018
                                                                                             var*1017
                                                                                             rhs*1016)
                                                                                           (if (memv
                                                                                                 t1025
                                                                                                 '(local-syntax))
                                                                                               (call-with-values
                                                                                                 (lambda ()
                                                                                                   (chi-local-syntax618
                                                                                                     value1023
                                                                                                     e1022
                                                                                                     r1020
                                                                                                     mr1019))
                                                                                                 (lambda (e*1036
                                                                                                          r1035
                                                                                                          mr1034)
                                                                                                   (parse1015
                                                                                                     (append
                                                                                                       e*1036
                                                                                                       (cdr e*1036))
                                                                                                     r1035
                                                                                                     mr1034
                                                                                                     id*1018
                                                                                                     var*1017
                                                                                                     rhs*1016)))
                                                                                               (begin
                                                                                                 (if (not (valid-bound-ids?143
                                                                                                            id*1018))
                                                                                                     (invalid-ids-error145
                                                                                                       id*1018
                                                                                                       outer-e1012
                                                                                                       '"locally defined identifier"))
                                                                                                 (build-letrec*34
                                                                                                   no-source3
                                                                                                   (reverse
                                                                                                     var*1017)
                                                                                                   (chi-exprs611
                                                                                                     (reverse
                                                                                                       rhs*1016)
                                                                                                     r1020
                                                                                                     mr1019)
                                                                                                   (build-sequence32
                                                                                                     no-source3
                                                                                                     (chi-exprs611
                                                                                                       (cons
                                                                                                         e1022
                                                                                                         (cdr e*1021))
                                                                                                       r1020
                                                                                                       mr1019))))))))))
                                                                          type1024))))
                                                                   (car e*1021))))])
                                         parse1015)
                                        (map (lambda (e1014)
                                               (add-subst113
                                                 rib1013
                                                 e1014))
                                             e*1011)
                                        r1010 mr1009 '() '() '()))
                                     (make-empty-rib122)))]
                    [parse-define615 (lambda (e981)
                                       (letrec* ([valid-args?982 (lambda (args999)
                                                                   (valid-bound-ids?143
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
                                         ((lambda (tmp983)
                                            ((lambda (tmp984)
                                               (if (if tmp984
                                                       (apply
                                                         (lambda (name986
                                                                  e985)
                                                           (id?135
                                                             name986))
                                                         tmp984)
                                                       '#f)
                                                   (apply
                                                     (lambda (name988 e987)
                                                       (values
                                                         name988
                                                         e987))
                                                     tmp984)
                                                   ((lambda (tmp989)
                                                      (if (if tmp989
                                                              (apply
                                                                (lambda (name993
                                                                         args992
                                                                         e1991
                                                                         e2990)
                                                                  (if (id?135
                                                                        name993)
                                                                      (valid-args?982
                                                                        args992)
                                                                      '#f))
                                                                tmp989)
                                                              '#f)
                                                          (apply
                                                            (lambda (name997
                                                                     args996
                                                                     e1995
                                                                     e2994)
                                                              (values
                                                                name997
                                                                (cons
                                                                  '#(syntax-object
                                                                     lambda
                                                                     (top)
                                                                     ())
                                                                  (cons
                                                                    args996
                                                                    (cons
                                                                      e1995
                                                                      e2994)))))
                                                            tmp989)
                                                          (syntax-error
                                                            tmp983)))
                                                     ($syntax-dispatch
                                                       tmp983
                                                       '(_ (any . any)
                                                           any
                                                           .
                                                           each-any)))))
                                              ($syntax-dispatch
                                                tmp983
                                                '(_ any any))))
                                           e981)))]
                    [parse-define-syntax616 (lambda (e974)
                                              ((lambda (tmp975)
                                                 ((lambda (tmp976)
                                                    (if (if tmp976
                                                            (apply
                                                              (lambda (name978
                                                                       rhs977)
                                                                (id?135
                                                                  name978))
                                                              tmp976)
                                                            '#f)
                                                        (apply
                                                          (lambda (name980
                                                                   rhs979)
                                                            (values
                                                              name980
                                                              rhs979))
                                                          tmp976)
                                                        (syntax-error
                                                          tmp975)))
                                                   ($syntax-dispatch
                                                     tmp975
                                                     '(_ any any))))
                                                e974))]
                    [parse-begin617 (lambda (e967 empty-okay?966)
                                      ((lambda (tmp968)
                                         ((lambda (tmp969)
                                            (if (if tmp969
                                                    (apply
                                                      (lambda ()
                                                        empty-okay?966)
                                                      tmp969)
                                                    '#f)
                                                (apply
                                                  (lambda () '())
                                                  tmp969)
                                                ((lambda (tmp970)
                                                   (if tmp970
                                                       (apply
                                                         (lambda (e1972
                                                                  e2971)
                                                           (cons
                                                             e1972
                                                             e2971))
                                                         tmp970)
                                                       (syntax-error
                                                         tmp968)))
                                                  ($syntax-dispatch
                                                    tmp968
                                                    '(_ any . each-any)))))
                                           ($syntax-dispatch tmp968 '(_))))
                                        e967))]
                    [chi-local-syntax618 (lambda (rec?947 e946 r945 mr944)
                                           ((lambda (tmp948)
                                              ((lambda (tmp949)
                                                 (if tmp949
                                                     (apply
                                                       (lambda (id953
                                                                rhs952
                                                                e1951
                                                                e2950)
                                                         ((lambda (id*957
                                                                   rhs*956)
                                                            (begin
                                                              (if (not (valid-bound-ids?143
                                                                         id*957))
                                                                  (invalid-ids-error145
                                                                    id*957
                                                                    e946
                                                                    '"keyword"))
                                                              ((lambda (label*959)
                                                                 ((lambda (rib960)
                                                                    ((lambda (b*963)
                                                                       (values
                                                                         (map (lambda (e965)
                                                                                (add-subst113
                                                                                  rib960
                                                                                  e965))
                                                                              (cons
                                                                                e1951
                                                                                e2950))
                                                                         (extend-env*131
                                                                           label*959
                                                                           b*963
                                                                           r945)
                                                                         (extend-env*131
                                                                           label*959
                                                                           b*963
                                                                           mr944)))
                                                                      (map (lambda (x962)
                                                                             (eval-transformer134
                                                                               (chi610
                                                                                 x962
                                                                                 mr944
                                                                                 mr944)))
                                                                           (if rec?947
                                                                               (map (lambda (x961)
                                                                                      (add-subst113
                                                                                        rib960
                                                                                        x961))
                                                                                    rhs*956)
                                                                               rhs*956))))
                                                                   (make-full-rib124
                                                                     id*957
                                                                     label*959)))
                                                                (map (lambda (x958)
                                                                       (gen-label125))
                                                                     id*957))))
                                                           id953
                                                           rhs952))
                                                       tmp949)
                                                     (syntax-error
                                                       tmp948)))
                                                ($syntax-dispatch
                                                  tmp948
                                                  '(_ #(each (any any))
                                                      any
                                                      .
                                                      each-any))))
                                             e946))]
                    [ellipsis?619 (lambda (x943)
                                    (if (id?135 x943)
                                        (free-id=?140
                                          x943
                                          '#(syntax-object ... (top) ()))
                                        '#f))])
            (begin
              (set! sc-expand
                (lambda (x942)
                  (chi610
                    (make-syntax-object94 x942 top-mark*105 top-subst*112)
                    null-env129
                    null-env129)))
              (global-extend9 'begin 'begin '#f)
              (global-extend9 'define 'define '#f)
              (global-extend9 'define-syntax 'define-syntax '#f)
              (global-extend9 'local-syntax 'letrec-syntax '#t)
              (global-extend9 'local-syntax 'let-syntax '#f)
              (global-extend9
                'core
                'quote
                (lambda (e938 r937 mr936)
                  ((lambda (tmp939)
                     ((lambda (tmp940)
                        (if tmp940
                            (apply
                              (lambda (e941)
                                (build-data31
                                  (syn->src103 e941)
                                  (strip102 e941 '())))
                              tmp940)
                            (syntax-error tmp939)))
                       ($syntax-dispatch tmp939 '(_ any))))
                    e938)))
              (global-extend9
                'core
                'lambda
                (lambda (e907 r906 mr905)
                  (letrec* ([help908 (lambda (var*930 rest?929 e*928)
                                       (begin
                                         (if (not (valid-bound-ids?143
                                                    var*930))
                                             (invalid-ids-error145
                                               var*930
                                               e907
                                               '"parameter"))
                                         ((lambda (label*933 new-var*932)
                                            (build-lambda29
                                              (syn->src103 e907)
                                              new-var*932
                                              rest?929
                                              (chi-body614
                                                e907
                                                ((lambda (rib934)
                                                   (map (lambda (e935)
                                                          (add-subst113
                                                            rib934
                                                            e935))
                                                        e*928))
                                                  (make-full-rib124
                                                    var*930
                                                    label*933))
                                                (extend-var-env*132
                                                  label*933
                                                  new-var*932
                                                  r906)
                                                mr905)))
                                           (map (lambda (x931)
                                                  (gen-label125))
                                                var*930)
                                           (map gen-var137 var*930))))])
                    ((lambda (tmp909)
                       ((lambda (tmp910)
                          (if tmp910
                              (apply
                                (lambda (var913 e1912 e2911)
                                  (help908 var913 '#f (cons e1912 e2911)))
                                tmp910)
                              ((lambda (tmp916)
                                 (if tmp916
                                     (apply
                                       (lambda (var920 rvar919 e1918 e2917)
                                         (help908
                                           (append
                                             var920
                                             (cons rvar919 '()))
                                           '#t
                                           (cons e1918 e2917)))
                                       tmp916)
                                     ((lambda (tmp923)
                                        (if tmp923
                                            (apply
                                              (lambda (var926 e1925 e2924)
                                                (help908
                                                  (cons var926 '())
                                                  '#t
                                                  (cons e1925 e2924)))
                                              tmp923)
                                            (syntax-error tmp909)))
                                       ($syntax-dispatch
                                         tmp909
                                         '(_ any any . each-any)))))
                                ($syntax-dispatch
                                  tmp909
                                  '(_ #(each+ any () any)
                                      any
                                      .
                                      each-any)))))
                         ($syntax-dispatch
                           tmp909
                           '(_ each-any any . each-any))))
                      e907))))
              (global-extend9
                'core
                'letrec
                (lambda (e885 r884 mr883)
                  ((lambda (tmp886)
                     ((lambda (tmp887)
                        (if tmp887
                            (apply
                              (lambda (var891 rhs890 e1889 e2888)
                                ((lambda (var*897 rhs*896 e*895)
                                   (begin
                                     (if (not (valid-bound-ids?143
                                                var*897))
                                         (invalid-ids-error145
                                           var*897
                                           e885
                                           '"bound variable"))
                                     ((lambda (label*900 new-var*899)
                                        ((lambda (r902 rib901)
                                           (build-letrec33
                                             (syn->src103 e885)
                                             new-var*899
                                             (map (lambda (e904)
                                                    (chi610
                                                      (add-subst113
                                                        rib901
                                                        e904)
                                                      r902
                                                      mr883))
                                                  rhs*896)
                                             (chi-body614
                                               e885
                                               (map (lambda (e903)
                                                      (add-subst113
                                                        rib901
                                                        e903))
                                                    e*895)
                                               r902
                                               mr883)))
                                          (extend-var-env*132
                                            label*900
                                            new-var*899
                                            r884)
                                          (make-full-rib124
                                            var*897
                                            label*900)))
                                       (map (lambda (x898) (gen-label125))
                                            var*897)
                                       (map gen-var137 var*897))))
                                  var891
                                  rhs890
                                  (cons e1889 e2888)))
                              tmp887)
                            (syntax-error tmp886)))
                       ($syntax-dispatch
                         tmp886
                         '(_ #(each (any any)) any . each-any))))
                    e885)))
              (global-extend9
                'core
                'letrec*
                (lambda (e863 r862 mr861)
                  ((lambda (tmp864)
                     ((lambda (tmp865)
                        (if tmp865
                            (apply
                              (lambda (var869 rhs868 e1867 e2866)
                                ((lambda (var*875 rhs*874 e*873)
                                   (begin
                                     (if (not (valid-bound-ids?143
                                                var*875))
                                         (invalid-ids-error145
                                           var*875
                                           e863
                                           '"bound variable"))
                                     ((lambda (label*878 new-var*877)
                                        ((lambda (r880 rib879)
                                           (build-letrec*34
                                             (syn->src103 e863)
                                             new-var*877
                                             (map (lambda (e882)
                                                    (chi610
                                                      (add-subst113
                                                        rib879
                                                        e882)
                                                      r880
                                                      mr861))
                                                  rhs*874)
                                             (chi-body614
                                               e863
                                               (map (lambda (e881)
                                                      (add-subst113
                                                        rib879
                                                        e881))
                                                    e*873)
                                               r880
                                               mr861)))
                                          (extend-var-env*132
                                            label*878
                                            new-var*877
                                            r862)
                                          (make-full-rib124
                                            var*875
                                            label*878)))
                                       (map (lambda (x876) (gen-label125))
                                            var*875)
                                       (map gen-var137 var*875))))
                                  var869
                                  rhs868
                                  (cons e1867 e2866)))
                              tmp865)
                            (syntax-error tmp864)))
                       ($syntax-dispatch
                         tmp864
                         '(_ #(each (any any)) any . each-any))))
                    e863)))
              (global-extend9
                'core
                'set!
                (lambda (e852 r851 mr850)
                  ((lambda (tmp853)
                     ((lambda (tmp854)
                        (if (if tmp854
                                (apply
                                  (lambda (id856 rhs855) (id?135 id856))
                                  tmp854)
                                '#f)
                            (apply
                              (lambda (id858 rhs857)
                                ((lambda (b859)
                                   ((lambda (t860)
                                      (if (memv t860 '(macro!))
                                          (chi610
                                            (chi-macro613
                                              (binding-value128 b859)
                                              e852)
                                            r851
                                            mr850)
                                          (if (memv t860 '(lexical))
                                              (build-lexical-assignment27
                                                (syn->src103 e852)
                                                (binding-value128 b859)
                                                (chi610 rhs857 r851 mr850))
                                              (if (memv t860 '(global))
                                                  (build-global-assignment28
                                                    (syn->src103 e852)
                                                    (binding-value128 b859)
                                                    (chi610
                                                      rhs857
                                                      r851
                                                      mr850))
                                                  (if (memv
                                                        t860
                                                        '(displaced-lexical))
                                                      (displaced-lexical-error133
                                                        id858)
                                                      (syntax-error93
                                                        e852))))))
                                     (binding-type127 b859)))
                                  (label->binding139
                                    (id->label138 id858)
                                    r851)))
                              tmp854)
                            (syntax-error tmp853)))
                       ($syntax-dispatch tmp853 '(_ any any))))
                    e852)))
              (global-extend9
                'core
                'if
                (lambda (e841 r840 mr839)
                  ((lambda (tmp842)
                     ((lambda (tmp843)
                        (if tmp843
                            (apply
                              (lambda (test845 then844)
                                (cons
                                  'if
                                  (cons
                                    (chi610 test845 r840 mr839)
                                    (cons
                                      (chi610 then844 r840 mr839)
                                      '()))))
                              tmp843)
                            ((lambda (tmp846)
                               (if tmp846
                                   (apply
                                     (lambda (test849 then848 else847)
                                       (cons
                                         'if
                                         (cons
                                           (chi610 test849 r840 mr839)
                                           (cons
                                             (chi610 then848 r840 mr839)
                                             (cons
                                               (chi610 else847 r840 mr839)
                                               '())))))
                                     tmp846)
                                   (syntax-error tmp842)))
                              ($syntax-dispatch tmp842 '(_ any any any)))))
                       ($syntax-dispatch tmp842 '(_ any any))))
                    e841)))
              (global-extend9
                'core
                'syntax-case
                ((lambda ()
                   (letrec* ([convert-pattern729 (lambda (pattern788
                                                          keys787)
                                                   (letrec* ([cvt*789 (lambda (p*834
                                                                               n833
                                                                               ids832)
                                                                        (if (null?
                                                                              p*834)
                                                                            (values
                                                                              '()
                                                                              ids832)
                                                                            (call-with-values
                                                                              (lambda ()
                                                                                (cvt*789
                                                                                  (cdr p*834)
                                                                                  n833
                                                                                  ids832))
                                                                              (lambda (y836
                                                                                       ids835)
                                                                                (call-with-values
                                                                                  (lambda ()
                                                                                    (cvt790
                                                                                      (car p*834)
                                                                                      n833
                                                                                      ids835))
                                                                                  (lambda (x838
                                                                                           ids837)
                                                                                    (values
                                                                                      (cons
                                                                                        x838
                                                                                        y836)
                                                                                      ids837)))))))]
                                                             [cvt790 (lambda (p793
                                                                              n792
                                                                              ids791)
                                                                       (if (not (id?135
                                                                                  p793))
                                                                           ((lambda (tmp794)
                                                                              ((lambda (tmp795)
                                                                                 (if (if tmp795
                                                                                         (apply
                                                                                           (lambda (x797
                                                                                                    dots796)
                                                                                             (ellipsis?619
                                                                                               dots796))
                                                                                           tmp795)
                                                                                         '#f)
                                                                                     (apply
                                                                                       (lambda (x799
                                                                                                dots798)
                                                                                         (call-with-values
                                                                                           (lambda ()
                                                                                             (cvt790
                                                                                               x799
                                                                                               (+ n792
                                                                                                  '1)
                                                                                               ids791))
                                                                                           (lambda (p801
                                                                                                    ids800)
                                                                                             (values
                                                                                               (if (eq? p801
                                                                                                        'any)
                                                                                                   'each-any
                                                                                                   (vector
                                                                                                     'each
                                                                                                     p801))
                                                                                               ids800))))
                                                                                       tmp795)
                                                                                     ((lambda (tmp802)
                                                                                        (if (if tmp802
                                                                                                (apply
                                                                                                  (lambda (x806
                                                                                                           dots805
                                                                                                           y804
                                                                                                           z803)
                                                                                                    (ellipsis?619
                                                                                                      dots805))
                                                                                                  tmp802)
                                                                                                '#f)
                                                                                            (apply
                                                                                              (lambda (x810
                                                                                                       dots809
                                                                                                       y808
                                                                                                       z807)
                                                                                                (call-with-values
                                                                                                  (lambda ()
                                                                                                    (cvt790
                                                                                                      z807
                                                                                                      n792
                                                                                                      ids791))
                                                                                                  (lambda (z812
                                                                                                           ids811)
                                                                                                    (call-with-values
                                                                                                      (lambda ()
                                                                                                        (cvt*789
                                                                                                          y808
                                                                                                          n792
                                                                                                          ids811))
                                                                                                      (lambda (y814
                                                                                                               ids813)
                                                                                                        (call-with-values
                                                                                                          (lambda ()
                                                                                                            (cvt790
                                                                                                              x810
                                                                                                              (+ n792
                                                                                                                 '1)
                                                                                                              ids813))
                                                                                                          (lambda (x816
                                                                                                                   ids815)
                                                                                                            (values
                                                                                                              (list->vector
                                                                                                                (cons
                                                                                                                  'each+
                                                                                                                  (cons
                                                                                                                    x816
                                                                                                                    (cons
                                                                                                                      (reverse
                                                                                                                        y814)
                                                                                                                      (list
                                                                                                                        z812)))))
                                                                                                              ids815))))))))
                                                                                              tmp802)
                                                                                            ((lambda (tmp818)
                                                                                               (if tmp818
                                                                                                   (apply
                                                                                                     (lambda (x820
                                                                                                              y819)
                                                                                                       (call-with-values
                                                                                                         (lambda ()
                                                                                                           (cvt790
                                                                                                             y819
                                                                                                             n792
                                                                                                             ids791))
                                                                                                         (lambda (y822
                                                                                                                  ids821)
                                                                                                           (call-with-values
                                                                                                             (lambda ()
                                                                                                               (cvt790
                                                                                                                 x820
                                                                                                                 n792
                                                                                                                 ids821))
                                                                                                             (lambda (x824
                                                                                                                      ids823)
                                                                                                               (values
                                                                                                                 (cons
                                                                                                                   x824
                                                                                                                   y822)
                                                                                                                 ids823))))))
                                                                                                     tmp818)
                                                                                                   ((lambda (tmp825)
                                                                                                      (if tmp825
                                                                                                          (apply
                                                                                                            (lambda ()
                                                                                                              (values
                                                                                                                '()
                                                                                                                ids791))
                                                                                                            tmp825)
                                                                                                          ((lambda (tmp826)
                                                                                                             (if tmp826
                                                                                                                 (apply
                                                                                                                   (lambda (x827)
                                                                                                                     (call-with-values
                                                                                                                       (lambda ()
                                                                                                                         (cvt790
                                                                                                                           x827
                                                                                                                           n792
                                                                                                                           ids791))
                                                                                                                       (lambda (p829
                                                                                                                                ids828)
                                                                                                                         (values
                                                                                                                           (vector
                                                                                                                             'vector
                                                                                                                             p829)
                                                                                                                           ids828))))
                                                                                                                   tmp826)
                                                                                                                 ((lambda (x831)
                                                                                                                    (values
                                                                                                                      (vector
                                                                                                                        'atom
                                                                                                                        (strip102
                                                                                                                          p793
                                                                                                                          '()))
                                                                                                                      ids791))
                                                                                                                   tmp794)))
                                                                                                            ($syntax-dispatch
                                                                                                              tmp794
                                                                                                              '#(vector
                                                                                                                 each-any)))))
                                                                                                     ($syntax-dispatch
                                                                                                       tmp794
                                                                                                       '()))))
                                                                                              ($syntax-dispatch
                                                                                                tmp794
                                                                                                '(any .
                                                                                                      any)))))
                                                                                       ($syntax-dispatch
                                                                                         tmp794
                                                                                         '(any any
                                                                                               .
                                                                                               #(each+
                                                                                                 any
                                                                                                 ()
                                                                                                 any))))))
                                                                                ($syntax-dispatch
                                                                                  tmp794
                                                                                  '(any any))))
                                                                             p793)
                                                                           (if (bound-id-member?142
                                                                                 p793
                                                                                 keys787)
                                                                               (values
                                                                                 (vector
                                                                                   'free-id
                                                                                   p793)
                                                                                 ids791)
                                                                               (if (free-id=?140
                                                                                     p793
                                                                                     '#(syntax-object
                                                                                        _
                                                                                        (top)
                                                                                        ()))
                                                                                   (values
                                                                                     '_
                                                                                     ids791)
                                                                                   (values
                                                                                     'any
                                                                                     (cons
                                                                                       (cons
                                                                                         p793
                                                                                         n792)
                                                                                       ids791))))))])
                                                     (cvt790
                                                       pattern788
                                                       '0
                                                       '())))]
                             [build-dispatch-call730 (lambda (pvars779
                                                              expr778 y777
                                                              r776 mr775)
                                                       ((lambda (ids781
                                                                 levels780)
                                                          ((lambda (labels784
                                                                    new-vars783)
                                                             (build-application11
                                                               no-source3
                                                               (build-primref30
                                                                 no-source3
                                                                 'apply)
                                                               (list
                                                                 (build-lambda29
                                                                   no-source3
                                                                   new-vars783
                                                                   '#f
                                                                   (chi610
                                                                     (add-subst113
                                                                       (make-full-rib124
                                                                         ids781
                                                                         labels784)
                                                                       expr778)
                                                                     (extend-env*131
                                                                       labels784
                                                                       (map (lambda (var786
                                                                                     level785)
                                                                              (make-binding126
                                                                                'syntax
                                                                                (cons
                                                                                  var786
                                                                                  level785)))
                                                                            new-vars783
                                                                            (map cdr
                                                                                 pvars779))
                                                                       r776)
                                                                     mr775))
                                                                 y777)))
                                                            (map (lambda (x782)
                                                                   (gen-label125))
                                                                 ids781)
                                                            (map gen-var137
                                                                 ids781)))
                                                         (map car pvars779)
                                                         (map cdr
                                                              pvars779)))]
                             [gen-clause731 (lambda (x768 keys767
                                                     clauses766 r765 mr764
                                                     pat763 fender762
                                                     expr761)
                                              (call-with-values
                                                (lambda ()
                                                  (convert-pattern729
                                                    pat763
                                                    keys767))
                                                (lambda (p770 pvars769)
                                                  (if (not (distinct-bound-ids?144
                                                             (map car
                                                                  pvars769)))
                                                      (invalid-ids-error145
                                                        (map car pvars769)
                                                        pat763
                                                        '"pattern variable")
                                                      (if (not (andmap37
                                                                 (lambda (x771)
                                                                   (not (ellipsis?619
                                                                          (car x771))))
                                                                 pvars769))
                                                          (syntax-error93
                                                            pat763
                                                            '"misplaced ellipsis in syntax-case pattern")
                                                          ((lambda (y772)
                                                             (build-application11
                                                               no-source3
                                                               (build-lambda29
                                                                 no-source3
                                                                 (list
                                                                   y772)
                                                                 '#f
                                                                 (cons
                                                                   'if
                                                                   (cons
                                                                     ((lambda (tmp773)
                                                                        ((lambda (tmp774)
                                                                           (if tmp774
                                                                               (apply
                                                                                 (lambda ()
                                                                                   y772)
                                                                                 tmp774)
                                                                               (cons
                                                                                 'if
                                                                                 (cons
                                                                                   (build-lexical-reference26
                                                                                     no-source3
                                                                                     y772)
                                                                                   (cons
                                                                                     (build-dispatch-call730
                                                                                       pvars769
                                                                                       fender762
                                                                                       y772
                                                                                       r765
                                                                                       mr764)
                                                                                     (cons
                                                                                       (build-data31
                                                                                         no-source3
                                                                                         '#f)
                                                                                       '()))))))
                                                                          ($syntax-dispatch
                                                                            tmp773
                                                                            '#(atom
                                                                               #t))))
                                                                       fender762)
                                                                     (cons
                                                                       (build-dispatch-call730
                                                                         pvars769
                                                                         expr761
                                                                         (build-lexical-reference26
                                                                           no-source3
                                                                           y772)
                                                                         r765
                                                                         mr764)
                                                                       (cons
                                                                         (gen-syntax-case732
                                                                           x768
                                                                           keys767
                                                                           clauses766
                                                                           r765
                                                                           mr764)
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
                                                                       x768)
                                                                     (build-data31
                                                                       no-source3
                                                                       p770))))))
                                                            (gen-var137
                                                              '#(syntax-object
                                                                 tmp (top)
                                                                 ()))))))))]
                             [gen-syntax-case732 (lambda (x750 keys749
                                                          clauses748 r747
                                                          mr746)
                                                   (if (null? clauses748)
                                                       (build-application11
                                                         no-source3
                                                         (build-primref30
                                                           no-source3
                                                           'syntax-error)
                                                         (list
                                                           (build-lexical-reference26
                                                             no-source3
                                                             x750)))
                                                       ((lambda (tmp751)
                                                          ((lambda (tmp752)
                                                             (if tmp752
                                                                 (apply
                                                                   (lambda (pat754
                                                                            expr753)
                                                                     (if (if (id?135
                                                                               pat754)
                                                                             (if (not (bound-id-member?142
                                                                                        pat754
                                                                                        keys749))
                                                                                 (not (ellipsis?619
                                                                                        pat754))
                                                                                 '#f)
                                                                             '#f)
                                                                         (if (free-identifier=?
                                                                               pat754
                                                                               '#(syntax-object
                                                                                  _
                                                                                  (top)
                                                                                  ()))
                                                                             (chi610
                                                                               expr753
                                                                               r747
                                                                               mr746)
                                                                             ((lambda (label756
                                                                                       var755)
                                                                                (build-application11
                                                                                  no-source3
                                                                                  (build-lambda29
                                                                                    no-source3
                                                                                    (list
                                                                                      var755)
                                                                                    '#f
                                                                                    (chi610
                                                                                      (add-subst113
                                                                                        (make-full-rib124
                                                                                          (list
                                                                                            pat754)
                                                                                          (list
                                                                                            label756))
                                                                                        expr753)
                                                                                      (extend-env130
                                                                                        label756
                                                                                        (make-binding126
                                                                                          'syntax
                                                                                          (cons
                                                                                            var755
                                                                                            '0))
                                                                                        r747)
                                                                                      mr746))
                                                                                  (list
                                                                                    (build-lexical-reference26
                                                                                      no-source3
                                                                                      x750))))
                                                                               (gen-label125)
                                                                               (gen-var137
                                                                                 pat754)))
                                                                         (gen-clause731
                                                                           x750
                                                                           keys749
                                                                           (cdr clauses748)
                                                                           r747
                                                                           mr746
                                                                           pat754
                                                                           '#t
                                                                           expr753)))
                                                                   tmp752)
                                                                 ((lambda (tmp757)
                                                                    (if tmp757
                                                                        (apply
                                                                          (lambda (pat760
                                                                                   fender759
                                                                                   expr758)
                                                                            (gen-clause731
                                                                              x750
                                                                              keys749
                                                                              (cdr clauses748)
                                                                              r747
                                                                              mr746
                                                                              pat760
                                                                              fender759
                                                                              expr758))
                                                                          tmp757)
                                                                        (syntax-error93
                                                                          (car clauses748)
                                                                          '"invalid syntax-case clause")))
                                                                   ($syntax-dispatch
                                                                     tmp751
                                                                     '(any any
                                                                           any)))))
                                                            ($syntax-dispatch
                                                              tmp751
                                                              '(any any))))
                                                         (car clauses748))))])
                     (lambda (e735 r734 mr733)
                       ((lambda (tmp736)
                          ((lambda (tmp737)
                             (if tmp737
                                 (apply
                                   (lambda (expr740 key739 m738)
                                     (if (andmap37
                                           (lambda (x742)
                                             (if (id?135 x742)
                                                 (not (ellipsis?619 x742))
                                                 '#f))
                                           key739)
                                         ((lambda (x743)
                                            (build-application11
                                              (syn->src103 e735)
                                              (build-lambda29
                                                no-source3
                                                (list x743)
                                                '#f
                                                (gen-syntax-case732 x743
                                                  key739 m738 r734 mr733))
                                              (list
                                                (chi610
                                                  expr740
                                                  r734
                                                  mr733))))
                                           (gen-var137
                                             '#(syntax-object tmp (top)
                                                ())))
                                         (syntax-error93
                                           e735
                                           '"invalid literals list in")))
                                   tmp737)
                                 (syntax-error tmp736)))
                            ($syntax-dispatch
                              tmp736
                              '(_ any each-any . each-any))))
                         e735))))))
              (global-extend9
                'core
                'syntax
                ((lambda ()
                   (letrec* ([gen-syntax620 (lambda (src675 e674 r673
                                                     maps672 ellipsis?671)
                                              (if (id?135 e674)
                                                  ((lambda (label676)
                                                     ((lambda (b677)
                                                        (if (eq? (binding-type127
                                                                   b677)
                                                                 'syntax)
                                                            (call-with-values
                                                              (lambda ()
                                                                ((lambda (var.lev680)
                                                                   (gen-ref621
                                                                     src675
                                                                     (car var.lev680)
                                                                     (cdr var.lev680)
                                                                     maps672))
                                                                  (binding-value128
                                                                    b677)))
                                                              (lambda (var679
                                                                       maps678)
                                                                (values
                                                                  (cons
                                                                    'ref
                                                                    (cons
                                                                      var679
                                                                      '()))
                                                                  maps678)))
                                                            (if (ellipsis?671
                                                                  e674)
                                                                (syntax-error93
                                                                  src675
                                                                  '"misplaced ellipsis in syntax form")
                                                                (values
                                                                  (cons
                                                                    'quote
                                                                    (cons
                                                                      e674
                                                                      '()))
                                                                  maps672))))
                                                       (label->binding139
                                                         label676
                                                         r673)))
                                                    (id->label138 e674))
                                                  ((lambda (tmp681)
                                                     ((lambda (tmp682)
                                                        (if (if tmp682
                                                                (apply
                                                                  (lambda (dots684
                                                                           e683)
                                                                    (ellipsis?671
                                                                      dots684))
                                                                  tmp682)
                                                                '#f)
                                                            (apply
                                                              (lambda (dots686
                                                                       e685)
                                                                (gen-syntax620
                                                                  src675
                                                                  e685 r673
                                                                  maps672
                                                                  (lambda (x687)
                                                                    '#f)))
                                                              tmp682)
                                                            ((lambda (tmp688)
                                                               (if (if tmp688
                                                                       (apply
                                                                         (lambda (x691
                                                                                  dots690
                                                                                  y689)
                                                                           (ellipsis?671
                                                                             dots690))
                                                                         tmp688)
                                                                       '#f)
                                                                   (apply
                                                                     (lambda (x694
                                                                              dots693
                                                                              y692)
                                                                       ((letrec ([f698 (lambda (y700
                                                                                                k699)
                                                                                         ((lambda (tmp701)
                                                                                            ((lambda (tmp702)
                                                                                               (if tmp702
                                                                                                   (apply
                                                                                                     (lambda ()
                                                                                                       (k699
                                                                                                         maps672))
                                                                                                     tmp702)
                                                                                                   ((lambda (tmp703)
                                                                                                      (if (if tmp703
                                                                                                              (apply
                                                                                                                (lambda (dots705
                                                                                                                         y704)
                                                                                                                  (ellipsis?671
                                                                                                                    dots705))
                                                                                                                tmp703)
                                                                                                              '#f)
                                                                                                          (apply
                                                                                                            (lambda (dots707
                                                                                                                     y706)
                                                                                                              (f698
                                                                                                                y706
                                                                                                                (lambda (maps708)
                                                                                                                  (call-with-values
                                                                                                                    (lambda ()
                                                                                                                      (k699
                                                                                                                        (cons
                                                                                                                          '()
                                                                                                                          maps708)))
                                                                                                                    (lambda (x710
                                                                                                                             maps709)
                                                                                                                      (if (null?
                                                                                                                            (car maps709))
                                                                                                                          (syntax-error93
                                                                                                                            src675
                                                                                                                            '"extra ellipsis in syntax form")
                                                                                                                          (values
                                                                                                                            (gen-mappend623
                                                                                                                              x710
                                                                                                                              (car maps709))
                                                                                                                            (cdr maps709))))))))
                                                                                                            tmp703)
                                                                                                          (call-with-values
                                                                                                            (lambda ()
                                                                                                              (gen-syntax620
                                                                                                                src675
                                                                                                                y700
                                                                                                                r673
                                                                                                                maps672
                                                                                                                ellipsis?671))
                                                                                                            (lambda (y712
                                                                                                                     maps711)
                                                                                                              (call-with-values
                                                                                                                (lambda ()
                                                                                                                  (k699
                                                                                                                    maps711))
                                                                                                                (lambda (x714
                                                                                                                         maps713)
                                                                                                                  (values
                                                                                                                    (gen-append622
                                                                                                                      x714
                                                                                                                      y712)
                                                                                                                    maps713)))))))
                                                                                                     ($syntax-dispatch
                                                                                                       tmp701
                                                                                                       '(any .
                                                                                                             any)))))
                                                                                              ($syntax-dispatch
                                                                                                tmp701
                                                                                                '())))
                                                                                           y700))])
                                                                          f698)
                                                                         y692
                                                                         (lambda (maps695)
                                                                           (call-with-values
                                                                             (lambda ()
                                                                               (gen-syntax620
                                                                                 src675
                                                                                 x694
                                                                                 r673
                                                                                 (cons
                                                                                   '()
                                                                                   maps695)
                                                                                 ellipsis?671))
                                                                             (lambda (x697
                                                                                      maps696)
                                                                               (if (null?
                                                                                     (car maps696))
                                                                                   (syntax-error93
                                                                                     src675
                                                                                     '"extra ellipsis in syntax form")
                                                                                   (values
                                                                                     (gen-map624
                                                                                       x697
                                                                                       (car maps696))
                                                                                     (cdr maps696))))))))
                                                                     tmp688)
                                                                   ((lambda (tmp715)
                                                                      (if tmp715
                                                                          (apply
                                                                            (lambda (x717
                                                                                     y716)
                                                                              (call-with-values
                                                                                (lambda ()
                                                                                  (gen-syntax620
                                                                                    src675
                                                                                    x717
                                                                                    r673
                                                                                    maps672
                                                                                    ellipsis?671))
                                                                                (lambda (xnew719
                                                                                         maps718)
                                                                                  (call-with-values
                                                                                    (lambda ()
                                                                                      (gen-syntax620
                                                                                        src675
                                                                                        y716
                                                                                        r673
                                                                                        maps718
                                                                                        ellipsis?671))
                                                                                    (lambda (ynew721
                                                                                             maps720)
                                                                                      (values
                                                                                        (gen-cons625
                                                                                          e674
                                                                                          x717
                                                                                          y716
                                                                                          xnew719
                                                                                          ynew721)
                                                                                        maps720))))))
                                                                            tmp715)
                                                                          ((lambda (tmp722)
                                                                             (if tmp722
                                                                                 (apply
                                                                                   (lambda (x1724
                                                                                            x2723)
                                                                                     ((lambda (ls726)
                                                                                        (call-with-values
                                                                                          (lambda ()
                                                                                            (gen-syntax620
                                                                                              src675
                                                                                              ls726
                                                                                              r673
                                                                                              maps672
                                                                                              ellipsis?671))
                                                                                          (lambda (lsnew728
                                                                                                   maps727)
                                                                                            (values
                                                                                              (gen-vector626
                                                                                                e674
                                                                                                ls726
                                                                                                lsnew728)
                                                                                              maps727))))
                                                                                       (cons
                                                                                         x1724
                                                                                         x2723)))
                                                                                   tmp722)
                                                                                 (values
                                                                                   (cons
                                                                                     'quote
                                                                                     (cons
                                                                                       e674
                                                                                       '()))
                                                                                   maps672)))
                                                                            ($syntax-dispatch
                                                                              tmp681
                                                                              '#(vector
                                                                                 (any .
                                                                                      each-any))))))
                                                                     ($syntax-dispatch
                                                                       tmp681
                                                                       '(any .
                                                                             any)))))
                                                              ($syntax-dispatch
                                                                tmp681
                                                                '(any any
                                                                      .
                                                                      any)))))
                                                       ($syntax-dispatch
                                                         tmp681
                                                         '(any any))))
                                                    e674)))]
                             [gen-ref621 (lambda (src665 var664 level663
                                                  maps662)
                                           (if (= level663 '0)
                                               (values var664 maps662)
                                               (if (null? maps662)
                                                   (syntax-error93
                                                     src665
                                                     '"missing ellipsis in syntax form")
                                                   (call-with-values
                                                     (lambda ()
                                                       (gen-ref621
                                                         src665
                                                         var664
                                                         (- level663 '1)
                                                         (cdr maps662)))
                                                     (lambda (outer-var667
                                                              outer-maps666)
                                                       ((lambda (t668)
                                                          (if t668
                                                              ((lambda (b669)
                                                                 (values
                                                                   (cdr b669)
                                                                   maps662))
                                                                t668)
                                                              ((lambda (inner-var670)
                                                                 (values
                                                                   inner-var670
                                                                   (cons
                                                                     (cons
                                                                       (cons
                                                                         outer-var667
                                                                         inner-var670)
                                                                       (car maps662))
                                                                     outer-maps666)))
                                                                (gen-var137
                                                                  '#(syntax-object
                                                                     tmp
                                                                     (top)
                                                                     ())))))
                                                         (assq
                                                           outer-var667
                                                           (car maps662))))))))]
                             [gen-append622 (lambda (x661 y660)
                                              (if (equal? y660 ''())
                                                  x661
                                                  (cons
                                                    'append
                                                    (cons
                                                      x661
                                                      (cons y660 '())))))]
                             [gen-mappend623 (lambda (e659 map-env658)
                                               (cons
                                                 'apply
                                                 (cons
                                                   '(primitive append)
                                                   (cons
                                                     (gen-map624
                                                       e659
                                                       map-env658)
                                                     '()))))]
                             [gen-map624 (lambda (e651 map-env650)
                                           ((lambda (formals654 actuals653)
                                              (if (eq? (car e651) 'ref)
                                                  (car actuals653)
                                                  (if (andmap37
                                                        (lambda (x655)
                                                          (if (eq? (car x655)
                                                                   'ref)
                                                              (memq
                                                                (cadr x655)
                                                                formals654)
                                                              '#f))
                                                        (cdr e651))
                                                      (cons
                                                        'map
                                                        (cons
                                                          (cons
                                                            'primitive
                                                            (cons
                                                              (car e651)
                                                              '()))
                                                          (append
                                                            (map ((lambda (r656)
                                                                    (lambda (x657)
                                                                      (cdr (assq
                                                                             (cadr
                                                                               x657)
                                                                             r656))))
                                                                   (map cons
                                                                        formals654
                                                                        actuals653))
                                                                 (cdr e651))
                                                            '())))
                                                      (cons
                                                        'map
                                                        (cons
                                                          (cons
                                                            'lambda
                                                            (cons
                                                              formals654
                                                              (cons
                                                                e651
                                                                '())))
                                                          (append
                                                            actuals653
                                                            '()))))))
                                             (map cdr map-env650)
                                             (map (lambda (x652)
                                                    (cons
                                                      'ref
                                                      (cons
                                                        (car x652)
                                                        '())))
                                                  map-env650)))]
                             [gen-cons625 (lambda (e646 x645 y644 xnew643
                                                   ynew642)
                                            ((lambda (t647)
                                               (if (memv t647 '(quote))
                                                   (if (eq? (car xnew643)
                                                            'quote)
                                                       ((lambda (xnew649
                                                                 ynew648)
                                                          (if (if (eq? xnew649
                                                                       x645)
                                                                  (eq? ynew648
                                                                       y644)
                                                                  '#f)
                                                              (cons
                                                                'quote
                                                                (cons
                                                                  e646
                                                                  '()))
                                                              (cons
                                                                'quote
                                                                (cons
                                                                  (cons
                                                                    xnew649
                                                                    ynew648)
                                                                  '()))))
                                                         (cadr xnew643)
                                                         (cadr ynew642))
                                                       (if (eq? (cadr
                                                                  ynew642)
                                                                '())
                                                           (cons
                                                             'list
                                                             (cons
                                                               xnew643
                                                               '()))
                                                           (cons
                                                             'cons
                                                             (cons
                                                               xnew643
                                                               (cons
                                                                 ynew642
                                                                 '())))))
                                                   (if (memv t647 '(list))
                                                       (cons
                                                         'list
                                                         (cons
                                                           xnew643
                                                           (append
                                                             (cdr ynew642)
                                                             '())))
                                                       (cons
                                                         'cons
                                                         (cons
                                                           xnew643
                                                           (cons
                                                             ynew642
                                                             '()))))))
                                              (car ynew642)))]
                             [gen-vector626 (lambda (e641 ls640 lsnew639)
                                              (if (eq? (car lsnew639)
                                                       'quote)
                                                  (if (eq? (cadr lsnew639)
                                                           ls640)
                                                      (cons
                                                        'quote
                                                        (cons e641 '()))
                                                      (cons
                                                        'quote
                                                        (cons
                                                          (list->vector
                                                            (cadr
                                                              lsnew639))
                                                          '())))
                                                  (if (eq? (car lsnew639)
                                                           'list)
                                                      (cons
                                                        'vector
                                                        (append
                                                          (cdr lsnew639)
                                                          '()))
                                                      (cons
                                                        'list->vector
                                                        (cons
                                                          lsnew639
                                                          '())))))]
                             [regen627 (lambda (x636)
                                         ((lambda (t637)
                                            (if (memv t637 '(ref))
                                                (build-lexical-reference26
                                                  no-source3
                                                  (cadr x636))
                                                (if (memv
                                                      t637
                                                      '(primitive))
                                                    (build-primref30
                                                      no-source3
                                                      (cadr x636))
                                                    (if (memv
                                                          t637
                                                          '(quote))
                                                        (build-data31
                                                          no-source3
                                                          (cadr x636))
                                                        (if (memv
                                                              t637
                                                              '(lambda))
                                                            (build-lambda29
                                                              no-source3
                                                              (cadr x636)
                                                              '#f
                                                              (regen627
                                                                (caddr
                                                                  x636)))
                                                            (if (memv
                                                                  t637
                                                                  '(map))
                                                                ((lambda (ls638)
                                                                   (build-application11
                                                                     no-source3
                                                                     (build-primref30
                                                                       no-source3
                                                                       'map)
                                                                     ls638))
                                                                  (map regen627
                                                                       (cdr x636)))
                                                                (build-application11
                                                                  no-source3
                                                                  (build-primref30
                                                                    no-source3
                                                                    (car x636))
                                                                  (map regen627
                                                                       (cdr x636)))))))))
                                           (car x636)))])
                     (lambda (e630 r629 mr628)
                       ((lambda (tmp631)
                          ((lambda (tmp632)
                             (if tmp632
                                 (apply
                                   (lambda (x633)
                                     (call-with-values
                                       (lambda ()
                                         (gen-syntax620 e630 x633 r629 '()
                                           ellipsis?619))
                                       (lambda (e635 maps634)
                                         (regen627 e635))))
                                   tmp632)
                                 (syntax-error tmp631)))
                            ($syntax-dispatch tmp631 '(_ any))))
                         e630))))))))))
       (set! $syntax-dispatch
         (lambda (e529 p528)
           (letrec* ([join-wraps530 (lambda (m1*600 s1*599 e598)
                                      (letrec* ([cancel601 (lambda (ls1605
                                                                    ls2604)
                                                             ((letrec ([f606 (lambda (x608
                                                                                      ls1607)
                                                                               (if (null?
                                                                                     ls1607)
                                                                                   (cdr ls2604)
                                                                                   (cons
                                                                                     x608
                                                                                     (f606
                                                                                       (car ls1607)
                                                                                       (cdr ls1607)))))])
                                                                f606)
                                                               (car ls1605)
                                                               (cdr ls1605)))])
                                        ((lambda (m2*603 s2*602)
                                           (if (if (not (null? m1*600))
                                                   (if (not (null? m2*603))
                                                       (eq? (car m2*603)
                                                            the-anti-mark108)
                                                       '#f)
                                                   '#f)
                                               (values
                                                 (cancel601 m1*600 m2*603)
                                                 (cancel601 s1*599 s2*602))
                                               (values
                                                 (append m1*600 m2*603)
                                                 (append s1*599 s2*602))))
                                          (syntax-object-mark*97 e598)
                                          (syntax-object-subst*98 e598))))]
                     [wrap531 (lambda (m*595 s*594 e593)
                                (if (syntax-object?95 e593)
                                    (call-with-values
                                      (lambda ()
                                        (join-wraps530 m*595 s*594 e593))
                                      (lambda (m*597 s*596)
                                        (make-syntax-object94
                                          (syntax-object-expression96 e593)
                                          m*597
                                          s*596)))
                                    (make-syntax-object94
                                      e593
                                      m*595
                                      s*594)))]
                     [match-each532 (lambda (e588 p587 m*586 s*585)
                                      (if (pair? e588)
                                          ((lambda (first589)
                                             (if first589
                                                 ((lambda (rest590)
                                                    (if rest590
                                                        (cons
                                                          first589
                                                          rest590)
                                                        '#f))
                                                   (match-each532
                                                     (cdr e588)
                                                     p587
                                                     m*586
                                                     s*585))
                                                 '#f))
                                            (match538 (car e588) p587 m*586
                                              s*585 '()))
                                          (if (null? e588)
                                              '()
                                              (if (syntax-object?95 e588)
                                                  (call-with-values
                                                    (lambda ()
                                                      (join-wraps530
                                                        m*586
                                                        s*585
                                                        e588))
                                                    (lambda (m*592 s*591)
                                                      (match-each532
                                                        (syntax-object-expression96
                                                          e588)
                                                        p587
                                                        m*592
                                                        s*591)))
                                                  (if (annotation?4 e588)
                                                      (match-each532
                                                        (annotation-expression5
                                                          e588)
                                                        p587
                                                        m*586
                                                        s*585)
                                                      '#f)))))]
                     [match-each+533 (lambda (e574 x-pat573 y-pat572
                                              z-pat571 m*570 s*569 r568)
                                       ((letrec ([f575 (lambda (e578 m*577
                                                                s*576)
                                                         (if (pair? e578)
                                                             (call-with-values
                                                               (lambda ()
                                                                 (f575
                                                                   (cdr e578)
                                                                   m*577
                                                                   s*576))
                                                               (lambda (xr*581
                                                                        y-pat580
                                                                        r579)
                                                                 (if r579
                                                                     (if (null?
                                                                           y-pat580)
                                                                         ((lambda (xr582)
                                                                            (if xr582
                                                                                (values
                                                                                  (cons
                                                                                    xr582
                                                                                    xr*581)
                                                                                  y-pat580
                                                                                  r579)
                                                                                (values
                                                                                  '#f
                                                                                  '#f
                                                                                  '#f)))
                                                                           (match538
                                                                             (car e578)
                                                                             x-pat573
                                                                             m*577
                                                                             s*576
                                                                             '()))
                                                                         (values
                                                                           '()
                                                                           (cdr y-pat580)
                                                                           (match538
                                                                             (car e578)
                                                                             (car y-pat580)
                                                                             m*577
                                                                             s*576
                                                                             r579)))
                                                                     (values
                                                                       '#f
                                                                       '#f
                                                                       '#f))))
                                                             (if (syntax-object?95
                                                                   e578)
                                                                 (call-with-values
                                                                   (lambda ()
                                                                     (join-wraps530
                                                                       m*577
                                                                       s*576
                                                                       e578))
                                                                   (lambda (m*584
                                                                            s*583)
                                                                     (f575
                                                                       (syntax-object-expression96
                                                                         e578)
                                                                       m*584
                                                                       s*583)))
                                                                 (if (annotation?4
                                                                       e578)
                                                                     (f575
                                                                       (annotation-expression5
                                                                         e578)
                                                                       m*577
                                                                       s*576)
                                                                     (values
                                                                       '()
                                                                       y-pat572
                                                                       (match538
                                                                         e578
                                                                         z-pat571
                                                                         m*577
                                                                         s*576
                                                                         r568))))))])
                                          f575)
                                         e574
                                         m*570
                                         s*569))]
                     [match-each-any534 (lambda (e564 m*563 s*562)
                                          (if (pair? e564)
                                              ((lambda (l565)
                                                 (if l565
                                                     (cons
                                                       (wrap531
                                                         m*563
                                                         s*562
                                                         (car e564))
                                                       l565)
                                                     '#f))
                                                (match-each-any534
                                                  (cdr e564)
                                                  m*563
                                                  s*562))
                                              (if (null? e564)
                                                  '()
                                                  (if (syntax-object?95
                                                        e564)
                                                      (call-with-values
                                                        (lambda ()
                                                          (join-wraps530
                                                            m*563
                                                            s*562
                                                            e564))
                                                        (lambda (m*567
                                                                 s*566)
                                                          (match-each-any534
                                                            (syntax-object-expression96
                                                              e564)
                                                            m*567
                                                            s*566)))
                                                      (if (annotation?4
                                                            e564)
                                                          (match-each-any534
                                                            (annotation-expression5
                                                              e564)
                                                            m*563
                                                            s*562)
                                                          '#f)))))]
                     [match-empty535 (lambda (p560 r559)
                                       (if (null? p560)
                                           r559
                                           (if (eq? p560 '_)
                                               r559
                                               (if (eq? p560 'any)
                                                   (cons '() r559)
                                                   (if (pair? p560)
                                                       (match-empty535
                                                         (car p560)
                                                         (match-empty535
                                                           (cdr p560)
                                                           r559))
                                                       (if (eq? p560
                                                                'each-any)
                                                           (cons '() r559)
                                                           ((lambda (t561)
                                                              (if (memv
                                                                    t561
                                                                    '(each))
                                                                  (match-empty535
                                                                    (vector-ref
                                                                      p560
                                                                      '1)
                                                                    r559)
                                                                  (if (memv
                                                                        t561
                                                                        '(each+))
                                                                      (match-empty535
                                                                        (vector-ref
                                                                          p560
                                                                          '1)
                                                                        (match-empty535
                                                                          (reverse
                                                                            (vector-ref
                                                                              p560
                                                                              '2))
                                                                          (match-empty535
                                                                            (vector-ref
                                                                              p560
                                                                              '3)
                                                                            r559)))
                                                                      (if (memv
                                                                            t561
                                                                            '(free-id
                                                                               atom))
                                                                          r559
                                                                          (if (memv
                                                                                t561
                                                                                '(vector))
                                                                              (match-empty535
                                                                                (vector-ref
                                                                                  p560
                                                                                  '1)
                                                                                r559)
                                                                              (error-hook1
                                                                                '$syntax-dispatch
                                                                                '"invalid pattern"
                                                                                p560))))))
                                                             (vector-ref
                                                               p560
                                                               '0))))))))]
                     [combine536 (lambda (r*558 r557)
                                   (if (null? (car r*558))
                                       r557
                                       (cons
                                         (map car r*558)
                                         (combine536
                                           (map cdr r*558)
                                           r557))))]
                     [match*537 (lambda (e550 p549 m*548 s*547 r546)
                                  (if (null? p549)
                                      (if (null? e550) r546 '#f)
                                      (if (pair? p549)
                                          (if (pair? e550)
                                              (match538 (car e550)
                                                (car p549) m*548 s*547
                                                (match538 (cdr e550)
                                                  (cdr p549) m*548 s*547
                                                  r546))
                                              '#f)
                                          (if (eq? p549 'each-any)
                                              ((lambda (l551)
                                                 (if l551
                                                     (cons l551 r546)
                                                     '#f))
                                                (match-each-any534
                                                  e550
                                                  m*548
                                                  s*547))
                                              ((lambda (t552)
                                                 (if (memv t552 '(each))
                                                     (if (null? e550)
                                                         (match-empty535
                                                           (vector-ref
                                                             p549
                                                             '1)
                                                           r546)
                                                         ((lambda (r*553)
                                                            (if r*553
                                                                (combine536
                                                                  r*553
                                                                  r546)
                                                                '#f))
                                                           (match-each532
                                                             e550
                                                             (vector-ref
                                                               p549
                                                               '1)
                                                             m*548
                                                             s*547)))
                                                     (if (memv
                                                           t552
                                                           '(free-id))
                                                         (if (symbol? e550)
                                                             (if (free-id=?140
                                                                   (wrap531
                                                                     m*548
                                                                     s*547
                                                                     e550)
                                                                   (vector-ref
                                                                     p549
                                                                     '1))
                                                                 r546
                                                                 '#f)
                                                             '#f)
                                                         (if (memv
                                                               t552
                                                               '(each+))
                                                             (call-with-values
                                                               (lambda ()
                                                                 (match-each+533
                                                                   e550
                                                                   (vector-ref
                                                                     p549
                                                                     '1)
                                                                   (vector-ref
                                                                     p549
                                                                     '2)
                                                                   (vector-ref
                                                                     p549
                                                                     '3)
                                                                   m*548
                                                                   s*547
                                                                   r546))
                                                               (lambda (xr*556
                                                                        y-pat555
                                                                        r554)
                                                                 (if r554
                                                                     (if (null?
                                                                           y-pat555)
                                                                         (if (null?
                                                                               xr*556)
                                                                             (match-empty535
                                                                               (vector-ref
                                                                                 p549
                                                                                 '1)
                                                                               r554)
                                                                             (combine536
                                                                               xr*556
                                                                               r554))
                                                                         '#f)
                                                                     '#f)))
                                                             (if (memv
                                                                   t552
                                                                   '(atom))
                                                                 (if (equal?
                                                                       (vector-ref
                                                                         p549
                                                                         '1)
                                                                       (strip102
                                                                         e550
                                                                         m*548))
                                                                     r546
                                                                     '#f)
                                                                 (if (memv
                                                                       t552
                                                                       '(vector))
                                                                     (if (vector?
                                                                           e550)
                                                                         (match538
                                                                           (vector->list
                                                                             e550)
                                                                           (vector-ref
                                                                             p549
                                                                             '1)
                                                                           m*548
                                                                           s*547
                                                                           r546)
                                                                         '#f)
                                                                     (error-hook1
                                                                       '$syntax-dispatch
                                                                       '"invalid pattern"
                                                                       p549)))))))
                                                (vector-ref p549 '0))))))]
                     [match538 (lambda (e543 p542 m*541 s*540 r539)
                                 (if (not r539)
                                     '#f
                                     (if (eq? p542 '_)
                                         r539
                                         (if (eq? p542 'any)
                                             (cons
                                               (wrap531 m*541 s*540 e543)
                                               r539)
                                             (if (syntax-object?95 e543)
                                                 (call-with-values
                                                   (lambda ()
                                                     (join-wraps530
                                                       m*541
                                                       s*540
                                                       e543))
                                                   (lambda (m*545 s*544)
                                                     (match*537
                                                       (unannotate104
                                                         (syntax-object-expression96
                                                           e543))
                                                       p542 m*545 s*544
                                                       r539)))
                                                 (match*537
                                                   (unannotate104 e543)
                                                   p542 m*541 s*540
                                                   r539))))))])
             (match538 e529 p528 '() '() '()))))
       ((lambda ()
          (letrec* ([arg-check513 (lambda (pred?527 x526 who525)
                                    (if (not (pred?527 x526))
                                        (error-hook1
                                          who525
                                          '"invalid argument"
                                          x526)))])
            (begin
              (set! identifier? (lambda (x524) (id?135 x524)))
              (set! datum->syntax
                (lambda (id523 datum522)
                  (begin
                    (arg-check513 id?135 id523 'datum->syntax)
                    (make-syntax-object94
                      datum522
                      (syntax-object-mark*97 id523)
                      (syntax-object-subst*98 id523)))))
              (set! syntax->datum (lambda (x521) (strip102 x521 '())))
              (set! generate-temporaries
                (lambda (ls519)
                  (begin
                    (arg-check513 list? ls519 'generate-temporaries)
                    (map (lambda (x520)
                           (make-syntax-object94
                             x520
                             top-mark*105
                             top-subst*112))
                         ls519))))
              (set! free-identifier=?
                (lambda (x518 y517)
                  (begin
                    (arg-check513 id?135 x518 'free-identifier=?)
                    (arg-check513 id?135 y517 'free-identifier=?)
                    (free-id=?140 x518 y517))))
              (set! bound-identifier=?
                (lambda (x516 y515)
                  (begin
                    (arg-check513 id?135 x516 'bound-identifier=?)
                    (arg-check513 id?135 y515 'bound-identifier=?)
                    (bound-id=?141 x516 y515))))
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
                                                   (syntax-error93 x467)))
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
                                                                                        (syntax-error93
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
                                                                                             syntax-error
                                                                                             let-values
                                                                                             define-structure
                                                                                             unless
                                                                                             when
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
                                                                           syntax-error
                                                                           let-values
                                                                           define-structure
                                                                           unless
                                                                           when
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
                                                                                              (syntax-error93
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
                                                                                                   syntax-error
                                                                                                   let-values
                                                                                                   define-structure
                                                                                                   unless
                                                                                                   when
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
                                                   (syntax-error93
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
                                                                                    syntax-error
                                                                                    let-values
                                                                                    define-structure
                                                                                    unless
                                                                                    when
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
                                                                             syntax-error
                                                                             let-values
                                                                             define-structure
                                                                             unless
                                                                             when
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
                                                                      syntax-error
                                                                      let-values
                                                                      define-structure
                                                                      unless
                                                                      when
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
                                                                                  syntax-error
                                                                                  let-values
                                                                                  define-structure
                                                                                  unless
                                                                                  when
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
                                                                                  syntax-error
                                                                                  let-values
                                                                                  define-structure
                                                                                  unless
                                                                                  when
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
                                                                                                          syntax-error
                                                                                                          let-values
                                                                                                          define-structure
                                                                                                          unless
                                                                                                          when
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
                                                                                                   syntax-error
                                                                                                   let-values
                                                                                                   define-structure
                                                                                                   unless
                                                                                                   when
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
                                                                                            syntax-error
                                                                                            let-values
                                                                                            define-structure
                                                                                            unless
                                                                                            when
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
                                                                syntax-error
                                                                let-values
                                                                define-structure
                                                                unless when
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
                                                                "i" "i" "i"
                                                                "i"
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
                                                                          syntax-error
                                                                          let-values
                                                                          define-structure
                                                                          unless
                                                                          when
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
                                                                   syntax-error
                                                                   let-values
                                                                   define-structure
                                                                   unless
                                                                   when
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
                                                                         syntax-error
                                                                         let-values
                                                                         define-structure
                                                                         unless
                                                                         when
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
                                                                   syntax-error
                                                                   let-values
                                                                   define-structure
                                                                   unless
                                                                   when
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
                                                            syntax-error
                                                            let-values
                                                            define-structure
                                                            unless when
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
                                                            "i" "i"
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
                                                    syntax-error let-values
                                                    define-structure unless
                                                    when andmap
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
                                                    (top) (top) (top))
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
                                                    "i" "i" "i" "i"
                                                    "i")))))
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
                         (syntax-error93
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
                         (syntax-error93
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
                                     syntax-error let-values
                                     define-structure unless when andmap
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
                                     (top) (top) (top) (top) (top))
                                    ("i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i" "i" "i" "i" "i" "i" "i" "i"
                                     "i" "i")))))
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
                                          syntax-error let-values
                                          define-structure unless when
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
                                          (top) (top) (top))
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
                                          "i" "i" "i")))))
                                  any
                                  any)
                                 any))))))
                ($syntax-dispatch tmp147 '(any any))))
             x146)))))))
