# FamilyOps 初期データ投入

# 育児カテゴリのタスク
childcare_tasks = [
  { name: "おむつ替え", description: "赤ちゃんのおむつを交換", points: 10 },
  { name: "授乳", description: "赤ちゃんに授乳する", points: 20 },
  { name: "離乳食の準備", description: "離乳食を作る", points: 30 },
  { name: "お風呂", description: "赤ちゃんをお風呂に入れる", points: 40 },
  { name: "寝かしつけ", description: "赤ちゃんを寝かしつける", points: 30 },
  { name: "お散歩", description: "赤ちゃんとお散歩する", points: 20 },
  { name: "遊び相手", description: "赤ちゃんと遊ぶ", points: 25 },
  { name: "着替え", description: "赤ちゃんの着替えをする", points: 15 }
]

# 家事カテゴリのタスク
housework_tasks = [
  { name: "食器洗い", description: "食器を洗う", points: 15 },
  { name: "洗濯", description: "洗濯物を洗う", points: 30 },
  { name: "洗濯物干し", description: "洗濯物を干す", points: 20 },
  { name: "洗濯物たたみ", description: "洗濯物をたたむ", points: 25 },
  { name: "掃除機", description: "掃除機をかける", points: 30 },
  { name: "お風呂掃除", description: "お風呂を掃除する", points: 40 },
  { name: "トイレ掃除", description: "トイレを掃除する", points: 35 },
  { name: "ゴミ出し", description: "ゴミを出す", points: 20 },
  { name: "買い物", description: "食材や日用品を買い物する", points: 30 },
  { name: "料理", description: "食事を作る", points: 50 }
]

puts "家事マスターデータを投入中..."

# 育児カテゴリのタスクを作成
childcare_tasks.each do |task_data|
  task = Task.find_or_create_by(name: task_data[:name], category: :childcare) do |t|
    t.description = task_data[:description]
    t.points = task_data[:points]
  end
  
  # 既存のタスクの場合はポイントを更新（必要に応じて）
  if task.persisted? && task.points != task_data[:points]
    task.update(points: task_data[:points])
  end
  
  puts "  ✓ #{task.name} (#{task.category}) - #{task.points}ポイント"
end

# 家事カテゴリのタスクを作成
housework_tasks.each do |task_data|
  task = Task.find_or_create_by(name: task_data[:name], category: :housework) do |t|
    t.description = task_data[:description]
    t.points = task_data[:points]
  end
  
  # 既存のタスクの場合はポイントを更新（必要に応じて）
  if task.persisted? && task.points != task_data[:points]
    task.update(points: task_data[:points])
  end
  
  puts "  ✓ #{task.name} (#{task.category}) - #{task.points}ポイント"
end

puts "家事マスターデータの投入が完了しました。"
puts "合計: #{Task.count}件のタスク"
