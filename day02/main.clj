(defn ok [n divisor lim]
  (and (= (mod n divisor) 0)
       (>= (/ n divisor) lim)
       (< (/ n divisor) (* 10 lim))))

(defn is-repnum? [divgen n]
  (loop [base 10]
    (if (>= base n)
      false
      (if
       (some
        #(ok n % (/ base 10))
        (take-while
         #(<= % n)
         (divgen base)))
        true
        (recur (* base 10))))))

(defn repnums-in-range [divgen start end]
  (filter (fn [n] (is-repnum? divgen n))
          (range start (inc end))))

(defn any-count [base]
  (drop 1
        (reductions
         (fn [acc _] (+ (* base acc) 1))
         1
         (cycle [1]))))

(defn parse-interval [interval-str]
  (map Long/parseLong
       (clojure.string/split interval-str #"-")))

(defn solve [divgen intervals]
  (reduce +
          (map
           #(let [[start end] (parse-interval %)]
              (reduce +
                      (repnums-in-range divgen start end)))

           intervals)))

(let [input (read-line)
      intervals (clojure.string/split input #",")]
  (println
   (str
    "Part 1: " (solve #(take 1 (any-count %)) intervals)
    "\n"
    "Part 2: " (solve any-count intervals))))
